
@description('Specifies the Azure location where the resources should be created.')
param location string

param env string

var managedIdentityName = '${env}-usermangedid-${location}'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

output manPrincipalId string  = managedIdentity.properties.principalId
output manPrincipalName string  = managedIdentity.name

