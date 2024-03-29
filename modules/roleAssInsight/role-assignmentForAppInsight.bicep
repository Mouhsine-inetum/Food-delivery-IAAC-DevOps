
@description('role definition id')
param ContributeRoleDefinitionId string

@description('role definition id')
param ReadRoleDefinitionId string

@description('principal id to will be given access to the resouurce')
param principalId string

@description('component name used for resource name')
param partName string 

var workspaceName ='wsa-${partName}'



var logSpaceName = 'wsa-${partName}'
var ContributeRoleAssignmentName = guid(logSpace.id, principalId, ContributeRoleDefinitionId)
var ReadRoleAssignmentName= guid(logSpace.id, principalId, ReadRoleDefinitionId)

resource logSpace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logSpaceName
}


resource contributeRoleAssignmentForLogSpace 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: ContributeRoleAssignmentName
  scope: logSpace
  properties: {
    roleDefinitionId: ContributeRoleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}


resource readRoleAssignmentForAppInsight 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: ReadRoleAssignmentName
  scope: logSpace
  properties: {
    roleDefinitionId: ReadRoleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}


