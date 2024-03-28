param partName string 
param location string
param branch string
param repoUrl string
param skuApiServiceName string
param skuApiServiceCapacity int

//tag infos
param owner string
param costCenter string
param application string
param descp string
param repo string
param version string

var managedIdName = 'muid-${partName}'

var tag = {
  owner: owner
  costCenter: costCenter
  application: application
  descp: descp
  repo: repo
  version : version
}

resource managedId 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: managedIdName
}


module webApiCreation '../../modules/webApp/application-web-api.bicep' = {
	name: 'web-api-deployment'
	params: {
		branch: branch
		location: location
		muiId: managedId.id
		repoURL: repoUrl
		skuCapacity: skuApiServiceCapacity
		skuName: skuApiServiceName
		partName: partName
	}
}

