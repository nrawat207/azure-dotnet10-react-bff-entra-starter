# Architecture

Browser -> same-origin ASP.NET Core BFF -> YARP -> downstream APIs. Entra ID authenticates the confidential server-side OIDC client. ASP.NET Core issues an HttpOnly session cookie. React calls `/bff/*` and `/api/*` with same-origin credentials; it does not use MSAL or store OAuth tokens.

YARP routes are configured in `appsettings.json`; routes should be explicit and each downstream cluster should have a health strategy, timeout, retry policy and authorization boundary appropriate to the API. Avoid blind retries for non-idempotent requests.
