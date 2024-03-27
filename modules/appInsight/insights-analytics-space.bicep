// Monitor

param location string

@description('metadata of the resource')
param tag object

@description('component name used for resource name')
param partName string 

var webApiName = 'wa-${partName}'

resource webApi 'Microsoft.Web/sites@2023-01-01' existing = {
  name: webApiName
}

var workspaceName ='wsa-${partName}'
var appinsightName ='ai-${partName}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  tags: tag
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appinsightName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}


var readRoleId= '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
@description('This is the built-in storage blob reader role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource insightsReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: readRoleId
}

var contributeRoleId = '92aaf0da-9dab-42b6-94a3-d43ce8d16293'
@description('This is the built-in storage blob reader role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource insightsContributeRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: contributeRoleId
}

output logSpaceId string = logAnalyticsWorkspace.id
output logSpaceName string = logAnalyticsWorkspace.name
output readRoleId string = insightsReaderRoleDefinition.id
output contributeRoleId string = insightsContributeRoleDefinition.id
