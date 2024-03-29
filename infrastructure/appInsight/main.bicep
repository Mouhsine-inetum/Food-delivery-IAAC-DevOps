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

module apiInsights '../../modules/appInsight/insights-analytics-space.bicep' = {
	name: 'appInsight-logspace-deployment'
	params: {
		tag: tag
    partName: partName
		location: location
	}
}


resource managedId 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: managedIdName
}

module roleAssignmentForAppInsight '../../modules/roleAssInsight/role-assignmentForAppInsight.bicep' = {
	name: 'role-assignment-insight'
	params: {
    partName: partName
		ContributeRoleDefinitionId: apiInsights.outputs.contributeRoleId
		principalId: managedId.properties.principalId
		ReadRoleDefinitionId: apiInsights.outputs.readRoleId
	}
}
