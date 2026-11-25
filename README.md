# Azure .NET 10 + React 19 + Entra BFF Starter

A same-origin Backend-for-Frontend starter: ASP.NET Core owns the OIDC confidential client, cookie session and YARP proxy. React never receives access or refresh tokens.

## Prerequisites
- .NET 10 SDK, Node.js 22+, npm, Docker Desktop
- Azure CLI + Bicep CLI for deployment
- Microsoft Entra app registration (Web platform; redirect URI `https://localhost:7043/signin-oidc`; front-channel logout `https://localhost:7043/signout-callback-oidc`)

## Quick start
1. Copy `.env.example` values into .NET user-secrets (do not commit secrets):
   ```bash
   cd src/backend/Starter.Bff
   dotnet user-secrets init
   dotnet user-secrets set "AzureAd:TenantId" "<tenant-id>"
   dotnet user-secrets set "AzureAd:ClientId" "<client-id>"
   dotnet user-secrets set "AzureAd:ClientSecret" "<secret>"
   ```
2. Install frontend dependencies and build: `cd ../../frontend/starter-web && npm install && npm run build`.
3. Run BFF: `cd ../../backend/Starter.Bff && dotnet run`. Browse to the HTTPS URL printed by ASP.NET Core.

The BFF serves `wwwroot`; copy the frontend `dist` output there using `scripts/build-frontend.sh` (or the Docker multi-stage build). For local Vite development, run `npm run dev`; Vite proxies `/bff` and `/api` to the BFF.

## Security model
- OIDC authorization-code flow handled only by server; client secret stays server-side.
- HttpOnly, Secure (outside Development), SameSite=Lax session cookie. Cookie is not an API bearer token.
- State-changing BFF requests require the antiforgery token from `/bff/antiforgery`; send it in `X-CSRF-TOKEN`.
- `/api/**` is authenticated before YARP forwards to configured downstream clusters. Configure real cluster destinations before use.
- Production requires shared ASP.NET Core Data Protection keys across replicas (for example Blob Storage), TLS, restrictive CORS/hosts, monitoring, secret rotation and review of downstream authorization.

## Build & test
```bash
dotnet restore src/backend/Starter.sln
dotnet build src/backend/Starter.sln -c Release
cd src/frontend/starter-web && npm ci && npm run build && npm test
````

## Azure deployment
See `docs/deployment/azure.md`. Deploy infrastructure first, build/push the image to ACR, then update the Container App image. Bicep intentionally accepts existing ACR image references and does not create app registrations.

## Repository map
- `src/backend/Starter.Bff`: auth, BFF endpoints, YARP, static hosting.
- `src/frontend/starter-web`: React UI.
- `infra`: composable Azure Bicep modules.
- `pipelines`: Azure DevOps pipeline.
- `docs`: architecture, auth and deployment notes.
