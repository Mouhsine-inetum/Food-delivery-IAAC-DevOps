param partName string 
param location string
// param bindingName string
param containerName string

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


module functionApp '../../modules/funcApp/functionApp-integration.bicep' = {
	name: 'function-app-deployment'
	params: {
    partName: partName
		location: location
		// bindingName: bindingName
		nameOfContainer: containerName
	}
}


module roleAssignmentForfunctionApp '../../modules/roleAssFuncApp/role-assignmentForFunctionApp.bicep' = {
	name: 'role-assignment-function-app'
	params: {
    partName: partName
		principalId: functionApp.outputs.functionPrincipal
		storageDataRoleDefinitionId: functionApp.outputs.roleDefinitionForAppToStorage
		topicsListenerRoleDefinitionId: functionApp.outputs.sbListenRoleDefinition
	}
}
