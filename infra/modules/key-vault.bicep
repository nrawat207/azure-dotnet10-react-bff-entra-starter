param name string
param location string
param entraClientSecret string
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  properties: {
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    sku: { family: 'A' name: 'standard' }
    publicNetworkAccess: 'Enabled'
  }
}
resource clientSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: vault
  name: 'entra-client-secret'
  properties: { value: entraClientSecret }
}
output name string = vault.name
output id string = vault.id
output secretUri string = clientSecret.properties.secretUriWithVersion
