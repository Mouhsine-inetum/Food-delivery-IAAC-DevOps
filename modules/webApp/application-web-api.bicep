@description('Specifies region for all resources')
param location string

@description('Specifies app plan SKU')
param skuName string //= 'F1'

@description('Specifies app plan capacity')
param skuCapacity int //= 1


@description('the name of the managed identity to access keyvault')
param muiId string

@description('component name used for resource name')
param partName string 

var appServiceName= 'as-${partName}'
var webApiName= 'wa-${partName}'


@secure()
@description('the url of the repositery where the code is')
param repoURL string


@description('the branch in the repo where the code is')
param branch string 

// var connStringName='FoodDeliveryDbConnectionString'


// Web App resources
resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServiceName
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }

}


resource webApi 'Microsoft.Web/sites@2023-01-01' = {
  name: webApiName
  location: location
  tags: {
    'hidden-related:${hostingPlan.id}': 'empty'
    displayName: 'Website'
  }
  properties: {
    serverFarmId: hostingPlan.id
    
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${muiId}': {}
    }
  }
}

resource ApiSourceControle 'Microsoft.Web/sites/sourcecontrols@2023-01-01' = {
  parent: webApi
  name: 'web'
  properties: {
    repoUrl: repoURL
    branch: branch
    isManualIntegration: true
  }
}

 


output webApiId string = webApi.properties.outboundIpAddresses
output webApiName string = webApi.name
output webApiIp array = split(webApi.properties.outboundIpAddresses,',')
