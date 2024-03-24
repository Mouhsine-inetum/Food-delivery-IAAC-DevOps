@description('role definition name')
param ContributeRoleAssignmentName string

@description('role definition id')
param ContributeRoleDefinitionId string


@description('role definition name')
param ReadRoleAssignmentName string

@description('role definition id')
param ReadRoleDefinitionId string

@description('principal id to will be given access to the resouurce')
param principalId string

@description('log analytcs to give access to')
param logSpaceName string


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


