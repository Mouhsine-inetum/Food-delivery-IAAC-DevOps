param roleDefinitionId string

param principalId string

param serviceBusId string

@description('component name used for resource name')
param partName string 

var serviceBusName = 'sbn-${partName}' 
resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusName
}

var  roleAssignmentName = guid(serviceBusId, principalId, roleDefinitionId)
resource roleAssignmentForKeyVault 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  scope: serviceBus
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}


