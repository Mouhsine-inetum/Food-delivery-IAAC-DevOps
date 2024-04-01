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


module serviceBus '../../modules/sbTop/serviceBus-topics.bicep' = {
	name: 'service-bus-deployment'
	params: {
		tags: tag
		location: location 
		partName: partName
	}
}

resource managedId 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: managedIdName
}

module roleAssignmentForServiceBus '../../modules/roleAssSb/role-assignmentForServiceBus.bicep' = {
	name: 'role-assignment-service-bus'
	params: {
    partName: partName
		principalId: managedId.properties.principalId
		roleDefinitionId: serviceBus.outputs.sbSenderRoleDefinition
		serviceBusId: serviceBus.outputs.serviceBusId
	}
}
