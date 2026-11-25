param name string
param location string
param environmentId string
param image string
param targetPort int
param cpu int
param memory string
param minReplicas int
param maxReplicas int
param keyVaultSecretUri string
param keyVaultId string
param entraTenantId string
param entraClientId string
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = { name: '${name}-identity' location: location }
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' existing = { name: last(split(keyVaultId, '/')) }
resource secretsRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: vault
  name: guid(keyVaultId, identity.properties.principalId, 'KeyVaultSecretsUser')
  properties: {
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
  }
}
resource app 'Microsoft.App/containerApps@2024-03-01' = {
  name: name
  location: location
  identity: { type: 'UserAssigned' userAssignedIdentities: { '${identity.id}': {} } }
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: { external: true targetPort: targetPort transport: 'auto' allowInsecure: false }
      secrets: [ { name: 'entra-client-secret' keyVaultUrl: keyVaultSecretUri identity: identity.id } ]
    }
    template: {
      containers: [ {
        name: 'bff' image: image resources: { cpu: cpu memory: memory }
        env: [
          { name: 'ASPNETCORE_HTTP_PORTS' value: string(targetPort) }
          { name: 'AzureAd__TenantId' value: entraTenantId }
          { name: 'AzureAd__ClientId' value: entraClientId }
          { name: 'AzureAd__ClientSecret' secretRef: 'entra-client-secret' }
        ]
        probes: [ { type: 'Liveness' httpGet: { path: '/health/live' port: targetPort } initialDelaySeconds: 10 periodSeconds: 30 } ]
      } ]
      scale: { minReplicas: minReplicas maxReplicas: maxReplicas }
    }
  }
  dependsOn: [secretsRole]
}
output fqdn string = app.properties.configuration.ingress.fqdn
output identityPrincipalId string = identity.properties.principalId
