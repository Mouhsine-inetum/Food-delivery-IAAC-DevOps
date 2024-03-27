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

module managedIdModule '../../modules/managedId/managedId.bicep' = {
	name: 'managedIdDeploy'
	params: {
		location: location
    partName: partName
	}
}
