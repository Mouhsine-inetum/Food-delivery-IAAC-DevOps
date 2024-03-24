param location string
param env string

@description('Suffix for function app, storage account, and key vault names.')
param appNameSuffix string = uniqueString(resourceGroup().id)

@description('storage name.')
param storageAccountName string

@description('name of the function app')
param functionaAppName string ='MyServiceBusTriggeredFunction'

@description('name of the container to be created')
param nameOfContainer string


@description('name of the in value binded trigger')
param bindingName string 

var functionAppName = 'fn-${env}-${appNameSuffix}'
var appServicePlanName = 'FunctionPlan-${env}-${appNameSuffix}'
// var appInsightsName = 'AppInsights-${functionAppName}-${appNameSuffix}'
// var storageAccountName = 'fnstor${replace(appNameSuffix, '-', '')}'
var functionNameComputed = '${functionaAppName}-${env}-${location}'
var functionRuntime = 'dotnet'
// var workspaceName = 'workspace-${appNameSuffix}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
//   name: workspaceName
//   location: location
//   properties: {
    
//   }
// }

// resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
//   name: appInsightsName
//   location: location
//   kind: 'web'
//   properties: {
//     Application_Type: 'web'
//     publicNetworkAccessForIngestion: 'Enabled'
//     publicNetworkAccessForQuery: 'Enabled'
//     WorkspaceResourceId: logAnalyticsWorkspace.id
//   }
// }

resource plan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  kind: 'functionapp'
  sku: {
    name: 'B1'
  }
  properties: {}
}


var endpoint = '${storageAccount.properties.primaryEndpoints.blob}/${nameOfContainer}'
resource functionApp 'Microsoft.Web/sites@2020-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity:{
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage__accountname'
          value: storageAccount.name
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionRuntime
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name:'EndpointToBlob'

          value: endpoint
        }
        {
          name:'Name'
          value:nameOfContainer
        }
      ]
    }
    httpsOnly: true
  }
}

resource function 'Microsoft.Web/sites/functions@2023-01-01' = {
  parent: functionApp
  name: functionNameComputed
  properties: {

    script_href: 'https://github.com/Mouhsine-inetum/Food-delivery-productCreated-functionApp.git'
    config: {
      disabled: false
      bindings: [
        {
          name: bindingName
          type: 'serviceBusTrigger'
          direction: 'in'
          authLevel: 'function'
          methods: [
            'get'
          ]
        }
      ]
    }
  }
}


resource appToStorageRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
}





output functionPrincipal string = functionApp.identity.principalId
output roleDefinitionForAppToStorage string = appToStorageRoleDefinition.id

output functionId string = functionApp.id
output functionAppHostName string = functionApp.properties.defaultHostName
output functionName string = functionApp.name
