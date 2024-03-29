param partName string 
param apiConf array

module appConfiguration '../../modules/appConfig/appservice-setConfiguration.bicep' = {
	name: 'set-configuration-for-api'
	params: {
    partName: partName
		apiConfigSet: apiConf
		// funcAppName: functionApp.outputs.functionName
		// funcAppConfigSet: funAppConf
	}
}
