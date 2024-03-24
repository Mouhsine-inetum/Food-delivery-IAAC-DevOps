
param roleDefinitionId string

param principalId string

@description('component name used for resource name')
param partName string 

var keyVaultName = 'kv${replace(partName,'-','')}'

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

var roleAssignmentName = guid(keyVault.id, principalId, roleDefinitionId)

resource roleAssignmentForKeyVault 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  scope: keyVault
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}



