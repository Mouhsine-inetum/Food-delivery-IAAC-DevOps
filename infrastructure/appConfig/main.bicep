param partName string 
param apiConf array
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
module appConfiguration '../../modules/appConfig/appservice-setConfiguration.bicep' = {
	name: 'set-configuration-for-api'
	params: {
    partName: partName
		apiConfigSet: apiConf
		// funcAppName: functionApp.outputs.functionName
		// funcAppConfigSet: funAppConf
	}
}
