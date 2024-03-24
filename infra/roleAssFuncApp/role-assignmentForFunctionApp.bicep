@description('role definition name')
param storageDataRoleAssignmentName string

@description('role definition id')
param storageDataRoleDefinitionId string

@description('role definition name')
param topicsListenerRoleAssignmentName string

@description('role definition id')
param topicsListenerRoleDefinitionId string

@description('principal id to will be given access to the resouurce')
param principalId string

var storageServiceName = 'sa${replace(partName,'-','')}'

var serviceBusName = 'sbn-${partName}'

@description('component name used for resource name')
param partName string 

resource storageBlobService 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageServiceName
}

resource contributeRoleAssignmentForStorage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: storageDataRoleAssignmentName
  scope: storageBlobService
  properties: {
    roleDefinitionId: storageDataRoleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}


resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusName
}

resource contributeRoleAssignmentForServiceBus 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: topicsListenerRoleAssignmentName
  scope: serviceBus
  properties: {
    roleDefinitionId: topicsListenerRoleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}



