using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Identity.Web;
using Starter.Bff.Security;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddProblemDetails();
builder.Services.AddHealthChecks();
builder.Services.AddAntiforgery(options =>
{
    options.HeaderName = "X-CSRF-TOKEN";
    options.Cookie.Name = "__Host-starter.csrf";
    options.Cookie.HttpOnly = true; // Browser JavaScript receives the request token from JSON, never the cookie.
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    options.Cookie.SameSite = SameSiteMode.Strict;
});

builder.Services.AddAuthentication(options =>
{
    options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
})
.AddMicrosoftIdentityWebApp(builder.Configuration.GetSection("AzureAd"),
    openIdConnectScheme: OpenIdConnectDefaults.AuthenticationScheme,
    cookieScheme: CookieAuthenticationDefaults.AuthenticationScheme);

builder.Services.Configure<CookieAuthenticationOptions>(CookieAuthenticationDefaults.AuthenticationScheme, options =>
{
    options.Cookie.Name = builder.Configuration["Bff:CookieName"] ?? "__Host-starter.bff";
    options.Cookie.HttpOnly = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    options.Cookie.SameSite = SameSiteMode.Lax;
    options.Cookie.Path = "/";
    options.SlidingExpiration = true;
    options.ExpireTimeSpan = TimeSpan.FromHours(8);
    options.Events = new CookieAuthenticationEvents
    {
        OnRedirectToLogin = context =>
        {
            if (context.Request.Path.StartsWithSegments("/bff") || context.Request.Path.StartsWithSegments("/api"))
            {
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                return Task.CompletedTask;
            }
            context.Response.Redirect(context.RedirectUri);
            return Task.CompletedTask;
        }
    };
});

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("SignedIn", policy => policy.RequireAuthenticatedUser());
});

builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

// Trust forwarded headers only from explicitly configured proxies in production.
builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});

var app = builder.Build();
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler();
    app.UseHsts();
}
app.UseForwardedHeaders();
app.UseHttpsRedirection();
app.UseDefaultFiles();
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();
app.UseAntiforgery();

app.MapHealthChecks("/health/live").AllowAnonymous();
app.MapGet("/bff/antiforgery", (HttpContext context, IAntiforgery antiforgery) =>
{
    var tokens = antiforgery.GetAndStoreTokens(context);
    return Results.Ok(new { requestToken = tokens.RequestToken });
}).RequireAuthorization("SignedIn");

app.MapGet("/bff/user", (HttpContext context) =>
{
    var user = context.User;
    return Results.Ok(new
    {
        isAuthenticated = user.Identity?.IsAuthenticated ?? false,
        name = user.Identity?.Name,
        claims = user.Claims.Where(c => c.Type is "name" or "preferred_username" or "oid" or "roles")
            .Select(c => new { c.Type, c.Value })
    });
}).RequireAuthorization("SignedIn");

app.MapGet("/bff/login", (string? returnUrl) =>
{
    var destination = LocalRedirectPath(returnUrl);
    return Results.Challenge(new Microsoft.AspNetCore.Authentication.AuthenticationProperties
    { RedirectUri = destination }, [OpenIdConnectDefaults.AuthenticationScheme]);
}).AllowAnonymous();

app.MapPost("/bff/logout", async (HttpContext context) =>
{
    await context.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
    await context.SignOutAsync(OpenIdConnectDefaults.AuthenticationScheme,
        new Microsoft.AspNetCore.Authentication.AuthenticationProperties { RedirectUri = "/" });
}).RequireAuthorization("SignedIn").RequireAntiforgery();

// Proxy is authenticated at the gateway boundary. Add per-route authorization policies
// and downstream token forwarding before connecting production APIs.
app.MapReverseProxy().RequireAuthorization("SignedIn");
app.MapFallbackToFile("index.html");
app.Run();

static string LocalRedirectPath(string? value) =>
    !string.IsNullOrWhiteSpace(value) && value.StartsWith('/') && !value.StartsWith("//") ? value : "/";

public partial class Program;
