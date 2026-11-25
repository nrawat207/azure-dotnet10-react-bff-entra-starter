targetScope = 'resourceGroup'
@description('Short unique workload/environment prefix, e.g. acme-dev')
@minLength(3)
@maxLength(18)
param namePrefix string
param location string = resourceGroup().location
param environment string = 'dev'
param containerImage string
param containerPort int = 8080
param cpu int = 0.5
param memory string = '1Gi'
param minReplicas int = 1
param maxReplicas int = 3
param entraTenantId string
param entraClientId string
@secure()
param entraClientSecret string

var baseName = '${namePrefix}-${environment}'
module logs './modules/log-analytics.bicep' = { name: 'logs-${uniqueString(resourceGroup().id)}' params: { name: '${baseName}-logs' location: location } }
module env './modules/container-environment.bicep' = { name: 'aca-env-${uniqueString(resourceGroup().id)}' params: { name: '${baseName}-env' location: location logAnalyticsCustomerId: logs.outputs.customerId logAnalyticsSharedKey: logs.outputs.sharedKey } }
module vault './modules/key-vault.bicep' = { name: 'kv-${uniqueString(resourceGroup().id)}' params: { name: '${baseName}-kv-${uniqueString(resourceGroup().id)}' location: location entraClientSecret: entraClientSecret } }
module app './modules/container-app.bicep' = { name: 'bff-${uniqueString(resourceGroup().id)}' params: { name: '${baseName}-bff' location: location environmentId: env.outputs.environmentId image: containerImage targetPort: containerPort cpu: cpu memory: memory minReplicas: minReplicas maxReplicas: maxReplicas keyVaultSecretUri: vault.outputs.secretUri keyVaultId: vault.outputs.id entraTenantId: entraTenantId entraClientId: entraClientId entraClientSecret: entraClientSecret } }
output appUrl string = 'https://${app.outputs.fqdn}'
output keyVaultName string = vault.outputs.name
