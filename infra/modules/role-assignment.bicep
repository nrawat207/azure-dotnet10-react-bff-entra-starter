// Reusable RBAC module. Supply a role definition GUID and principal object ID.
param principalId string
param roleDefinitionGuid string
param principalType string = 'ServicePrincipal'
resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = { name: guid(resourceGroup().id, principalId, roleDefinitionGuid) properties: { principalId: principalId principalType: principalType roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionGuid) } }
output assignmentId string = assignment.id
