param partName string 
param location string

//tag infos
param owner string
param costCenter string
param application string
param descp string
param repo string
param version string

var tag = {
  owner: owner
  costCenter: costCenter
  application: application
  descp: descp
  repo: repo
  version : version
}
var managedIdName = 'muid-${partName}'

module storageAccountModule '../../modules/sa/storageAccount.bicep' = {
	name: 'storageAccountDeploy'
	params: {
		location: location
		partName:partName
    tags: tag
	}
}

resource managedId 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: managedIdName
}

module roleAssignmentForSA '../../modules/roleAssSa/role-assignmentForStorageAccount.bicep' = {
  name: 'role-assignment-sa'
  params: {
    partName: partName
    principalId: managedId.properties.principalId
  }
  dependsOn:[storageAccountModule]
}
