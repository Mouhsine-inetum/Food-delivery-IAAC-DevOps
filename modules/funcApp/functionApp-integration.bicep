param location string

@description('component name used for resource name')
param partName string 

@description('name of the container to be created')
param nameOfContainer string

param tags object

// @description('name of the in value binded trigger')
// param bindingName string 

var functionAppName = 'fa-${partName}'
var appServicePlanName = 'as-${partName}'
// var functionName = 'fn${partName}'
var functionRuntime = 'dotnet'
var storageAccountName = 'sa${toLower(replace(partName,'-',''))}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource plan 'Microsoft.Web/serverfarms@2020-12-01' existing = {
  name: appServicePlanName
}


var endpoint = '${storageAccount.properties.primaryEndpoints.blob}/${nameOfContainer}'
resource functionApp 'Microsoft.Web/sites@2020-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  tags:tags
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

// resource function 'Microsoft.Web/sites/functions@2023-01-01' = {
//   parent: functionApp
//   name: functionName
//   properties: {

//     script_href: 'https://github.com/Mouhsine-inetum/Food-delivery-productCreated-functionApp.git'
//     config: {
//       disabled: false
//       bindings: [
//         {
//           name: bindingName
//           type: 'serviceBusTrigger'
//           direction: 'in'
//           authLevel: 'function'
//           methods: [
//             'get'
//           ]
//         }
//       ]
//     }
//   }
// }


resource appToStorageRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
}



resource serviceBusListenRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
}



output functionPrincipal string = functionApp.identity.principalId
output roleDefinitionForAppToStorage string = appToStorageRoleDefinition.id
output sbListenRoleDefinition string = serviceBusListenRoleDefinition.id

output functionId string = functionApp.id
output functionAppHostName string = functionApp.properties.defaultHostName
output functionName string = functionApp.name
