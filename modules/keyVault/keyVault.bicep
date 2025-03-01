
// @description('Specifies the name of the key vault.')
// param keyVaultName string

@description('component name used for resource name')
param partName string 

@description('Specifies the SKU to use for the key vault.')
param keyVaultSku object = {
  name: 'standard'
  family: 'A'
}

@description('metadata of the resource')
param tag object

@description('Specifies the Azure location where the resources should be created.')
param location string

@description('This is the built-in Key Vault Administrator role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-administrator')
resource keyVaultAdministratorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}


var kvName= 'kv${toLower(replace(partName,'-',''))}'

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: kvName
  location: location
  tags: tag
  properties: {
    enableRbacAuthorization: true
    tenantId: tenant().tenantId
    sku: keyVaultSku
  }
}



output keyVaultNameOut string = keyVault.name
output keyVaultIdOut string = keyVault.id
output keyVaultRoleDefinition string = keyVaultAdministratorRoleDefinition.id

