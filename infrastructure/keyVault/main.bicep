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

module keyVaultModule '../../modules/keyVault/keyVault.bicep' = {
  name:'keyVaultDeploy'
  params:{
    tag: tag
    partName: partName
    location:location
  }
  }
  

  resource managedId 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
    name: managedIdName
  }
  
	module roleAssignmentForKV '../../modules/rolAssKv/role-assignmentForKeyVault.bicep' = {
		name: 'role-assignment-kv'
		params: {
			partName: partName
			roleDefinitionId: keyVaultModule.outputs.keyVaultRoleDefinition
			principalId: managedId.properties.principalId
		}
    dependsOn:[keyVaultModule]
	}
