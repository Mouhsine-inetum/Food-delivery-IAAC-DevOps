
@description('component name used for resource name')
param partName string 

// @description('storage name.')
// param storageAccountName string


// @description('name of the api')
// param funcAppName string

@description('name of the client domain')
param apiConfigSet array
// @description('name of the client domain')
// param funcAppConfigSet array


var webApiName = 'wa-${partName}'
resource webApi 'Microsoft.Web/sites@2023-01-01' existing = {
  name: webApiName
}

resource apiConfig 'Microsoft.Web/sites/config@2023-01-01' = [for item in apiConfigSet: {
  name: 'appsettings'
  parent: webApi
  properties: {
    '${item.name}' : item.value
  }
}]



// resource functionApp 'Microsoft.Web/sites@2023-01-01' existing = {
//   name: funcAppName
// }

// resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
//   name: storageAccountName
// }

// var endpoint = '${storageAccount.properties.primaryEndpoints.blob}/${nameOfContainer}'


// resource funAppConfig 'Microsoft.Web/sites/config@2023-01-01' = [for item in funcAppConfigSet: {
//   name: 'appsettings'
//   parent: functionApp
//   properties: {
//     '${item.name}' : item.value
//   }
// }]
