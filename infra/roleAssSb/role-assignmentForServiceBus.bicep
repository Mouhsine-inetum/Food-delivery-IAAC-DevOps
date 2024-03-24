param roleDefinitionId string

param principalId string

param keyVaultName string

param serviceBusId string

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

var  roleAssignmentName = guid(serviceBusId, principalId, roleDefinitionId)
resource roleAssignmentForKeyVault 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  scope: keyVault
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}


