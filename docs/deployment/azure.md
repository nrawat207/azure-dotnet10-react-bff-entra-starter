# Azure deployment

## Prerequisites
- Resource group, Azure CLI, Bicep, ACR and an Azure DevOps service connection.
- Entra app registration with the deployed callback URI.

## Deploy
```bash
az login
az group create -n rg-azstarter-dev -l centralindia
export ENTRA_CLIENT_SECRET='<secret>'
az deployment group create -g rg-azstarter-dev -f infra/main.bicep -p @infra/parameters/dev.bicepparam
```

Replace the sample image in `dev.bicepparam` with a real image in your ACR. For production, do not pass a long-lived secret through shell history or pipeline logs: provision it directly into Key Vault, use a managed identity Key Vault reference in Container Apps, and grant the app identity only `Key Vault Secrets User` on the vault. The Bicep modules create the Entra client secret in Key Vault and configure the Container App to reference the versioned secret URI using its user-assigned managed identity. The identity receives the Key Vault Secrets User role scoped to that vault.

## Production hardening checklist
- Use Key Vault references and managed identity; remove secret-valued pipeline parameters.
- Persist Data Protection keys to shared durable storage for multi-replica deployments.
- Restrict ingress, use private endpoints/VNet where required, and configure trusted forwarded headers.
- Add app-specific readiness checks, alerts, OpenTelemetry/Application Insights and log redaction.
- Configure scale rules, resource limits, revision strategy and rollback.
- Validate Entra redirect/logout URIs, tenant restrictions, app roles, consent and credential rotation.
