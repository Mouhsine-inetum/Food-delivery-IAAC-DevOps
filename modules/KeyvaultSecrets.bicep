
@description('name of the key vault')
param keyVaultName string

// @secure()
// @description('url of the cloudinary API')
// param secretUrlCloudinary string

// @secure()
// @description('Secret for the Auth0 Identity provider for user to machine communication')
// param secretForUserAuth0 string

// @secure()
// @description('Secret for the Auth0 Identity provider for machine to machine communication')
// param secretForMachineAuth0 string

@description('the envirionment')
param env string='dev'

@description('the array of secret to be implemented')
param secrets array = [
  {
    name: 'example'
    value:'example'
  }
]

var modifiedSecrets = [for item in secrets:{
  name:'${env}-${item.name}'
  value: item.value
} ]


 resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
 }

resource secretToKeyVault 'Microsoft.KeyVault/vaults/secrets@2023-07-01' =[for item in modifiedSecrets: {
  name: item.name
  properties:{
    value:item.value
  }

  parent:keyvault
}]
