//general
@description('Specifies the Azure location where the resources should be created.')
param location string = resourceGroup().location
@description('the component structure that will be used in name following a convention')
param partName string

@description('version of deployment')
param version int

@allowed([
	'dev'
	'acc'
	'prod'
])
@description('Environment in which the dploy is affected')
param env string


//tag infos
param owner string
param costCenter string
param application string
param descp string
param repo string

//sql server-db
@maxLength(20)
@minLength(5)
@description('the name of the database')
param databaseName string


@maxLength(18)
@minLength(5)
@secure()
@description('the name of the admin to login')
param sqlAdminlogin string


//keyvault 
@description('name of the keyvault')
@secure()
param keyVaulName string


@description('namle of the rg with the keyvault inside')
param kvRgName string


//storage account
var containerNames= [
'products'
'orders'
'stores'
]

//web api

@description('the branch in the repo where the code is')
param branch string='main'

@description('the git repo where the code is')
param repoUrl string

@description('the domain of the client that will conenct to the api')
param apiConf array

@description('the tier capacity of the app service server holding the api')
param skuApiServiceCapacity int

@description('the tiername  of the app service server holding the api')
param skuApiServiceName string




// function app

@description('the binding type required for the function')
param bindingName string 

@description('name of the container linked to the function app')
param containerName string 

// @description('the domain of the client that will conenct to the api')
// param funAppConf array

//variables
var tag = {
  owner: owner
  costCenter: costCenter
  application: application
  descp: descp
  repo: repo
}


//modules :

module managedIdModule './modules/managedId/managedId.bicep' = {
	name: 'managedIdDeploy'
	params: {
		location: location
    partName: partName
	}
}


module storageAccountModule './modules/sa/storageAccount.bicep' = {
	name: 'storageAccountDeploy'
	params: {
		location: location
		containerNames: containerNames
		partName:partName
	}
}

module keyVaultModule './modules/keyVault/keyVault.bicep' = {
  name:'keyVaultDeploy'
  params:{
    partName: partName
    location:location
  }
  }
  
  
	module roleAssignmentForKV './modules/rolAssKv/role-assignmentForKeyVault.bicep' = {
		name: 'role-assignment-kv'
		params: {
			partName: partName
			roleDefinitionId: keyVaultModule.outputs.keyVaultRoleDefinition
			principalId: managedIdModule.outputs.manPrincipalId
		}
	}

	module roleAssignmentForSA './modules/roleAssSa/role-assignmentForStorageAccount.bicep' = {
		name: 'role-assignment-sa'
		params: {
			partName: partName
			principalId: managedIdModule.outputs.manPrincipalId
		}
	}



resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaulName
  scope: resourceGroup(subscription().subscriptionId,kvRgName) 
}

module serverDatabaseforsql './modules/sqlDB/server-Database-SQL.bicep' = {
	name: 'server-database-deployment'
	params: {
		DbName: databaseName
		location: location
		sqlAdministratorLogin: sqlAdminlogin
		sqlAdministratorPassword: keyvault.getSecret('sqlPasswordAdmin')
		webappIp: webApiCreation.outputs.webApiIp
		partName: partName
	}
}


module webApiCreation './modules/webApp/application-web-api.bicep' = {
	name: 'web-api-deployment'
	params: {
		branch: branch
		location: location
		msiName: managedIdModule.outputs.manPrincipalName
		repoURL: repoUrl
		skuCapacity: skuApiServiceCapacity
		skuName: skuApiServiceName
		partName: partName
	}
}


module apiInsights './modules/appInsight/insights-analytics-space.bicep' = {
	name: 'appInsight-logspace-deployment'
	params: {
    partName: partName
		location: location
	}
}


module appConfiguration './modules/appConfig/appservice-setConfiguration.bicep' = {
	name: 'set-configuration-for-api'
	params: {
    partName: partName
		apiConfigSet: apiConf
		// funcAppName: functionApp.outputs.functionName
		// funcAppConfigSet: funAppConf
	}
}


module roleAssignmentForAppInsight './modules/roleAssInsight/role-assignmentForAppInsight.bicep' = {
	name: 'role-assignment-insight'
	params: {
    partName: partName
		ContributeRoleAssignmentName: guid(apiInsights.outputs.logSpaceId, managedIdModule.outputs.manPrincipalId, apiInsights.outputs.contributeRoleId)
		ContributeRoleDefinitionId: apiInsights.outputs.contributeRoleId
		principalId: managedIdModule.outputs.manPrincipalId
		ReadRoleAssignmentName: guid(apiInsights.outputs.logSpaceId, managedIdModule.outputs.manPrincipalId, apiInsights.outputs.readRoleId)
		ReadRoleDefinitionId: apiInsights.outputs.readRoleId
	}
}



module serviceBus './modules//sbTop/serviceBus-topics.bicep' = {
	name: 'service-bus-deployment'
	params: {
		location: location 
		partName: partName
	}
}



module roleAssignmentForServiceBus './modules/roleAssSb/role-assignmentForServiceBus.bicep' = {
	name: 'role-assignment-service-bus'
	params: {
    partName: partName
		principalId: managedIdModule.outputs.manPrincipalId
		roleDefinitionId: serviceBus.outputs.sbSenderRoleDefinition
		serviceBusId: serviceBus.outputs.serviceBusId
	}
}

module functionApp './modules/funcApp/functionApp-integration.bicep' = {
	name: 'function-app-deployment'
	params: {
    partName: partName
		location: location
		bindingName: bindingName
		nameOfContainer: containerName
	}
}

module roleAssignmentForfunctionApp './modules/roleAssFuncApp/role-assignmentForFunctionApp.bicep' = {
	name: 'role-assignment-function-app'
	params: {
    partName: partName
		principalId: functionApp.outputs.functionPrincipal
		storageDataRoleAssignmentName: guid(functionApp.outputs.functionId, functionApp.outputs.functionPrincipal, functionApp.outputs.roleDefinitionForAppToStorage)
		storageDataRoleDefinitionId: functionApp.outputs.roleDefinitionForAppToStorage
		topicsListenerRoleAssignmentName: guid(functionApp.outputs.functionId, functionApp.outputs.functionPrincipal, serviceBus.outputs.sbListenRoleDefinition)
		topicsListenerRoleDefinitionId: serviceBus.outputs.sbListenRoleDefinition
	}
}


// module addSecretInKeyVault 'modules/KeyvaultSecrets.bicep' = {
// 	name: 'creation-secrets-to-keyvault'
// 	params: {
// 		keyVaultName : keyVaultModule.outputs.keyVaultNameOut
// 		env: env
// 		secrets: secrets
// 	}
// }


