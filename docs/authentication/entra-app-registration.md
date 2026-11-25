# Entra app registration

1. Create an app registration for a Web application (confidential client).
2. Add redirect URI `https://localhost:7043/signin-oidc`.
3. Add front-channel logout URL `https://localhost:7043/signout-callback-oidc` if using front-channel logout.
4. Create a client credential for local development; prefer certificate or workload identity federation in production where supported. Store local secret with `dotnet user-secrets`; store production secret in Key Vault.
5. Configure supported account types and tenant restrictions intentionally.
6. Set the production redirect URI to the deployed HTTPS hostname.

Do not expose the client secret, authorization code, access token or refresh token to JavaScript. Review app roles and group overage behavior before using claims for authorization.
