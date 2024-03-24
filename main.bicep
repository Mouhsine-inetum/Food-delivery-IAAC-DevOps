//general
@description('Specifies the Azure location where the resources should be created.')
param location string = resourceGroup().location

@allowed([
	'dev'
	'acc'
	'prod'
])
@description('Environment in which the dploy is affected')
param env string


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

@description('name of the function app')
param functionAppName string

@description('the binding type required for the function')
param bindingName string 

@description('name of the container linked to the function app')
param containerName string 

// @description('the domain of the client that will conenct to the api')
// param funAppConf array


//modules :

module managedIdModule 'modules/managedId.bicep' = {
	name: 'managedIdDeploy'
	params: {
		location: location
		env:env
	}
}

module storageAccountModule 'modules/storageAccount.bicep' = {
	name: 'storageAccountDeploy'
	params: {
		location: location
		containerNames: containerNames
		env: env		
	}
}

module keyVaultModule 'modules/keyVault.bicep' = {
name:'keyVaultDeploy'
params:{
env: env
location:location
}
}

module roleAssignmentForKV 'modules/role-assignmentForKeyVault.bicep' = {
  name: 'role-assignment-kv'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultNameOut
    roleDefinitionId: keyVaultModule.outputs.keyVaultRoleDefinition
    principalId: managedIdModule.outputs.manPrincipalId
  }
}

module roleAssignmentForSA 'modules/role-assignmentForStorageAccount.bicep' = {
	name: 'role-assignment-sa'
	params: {
		principalId: managedIdModule.outputs.manPrincipalId
		roleAssignmentName: guid(storageAccountModule.outputs.idStorage, managedIdModule.outputs.manPrincipalId, storageAccountModule.outputs.storageRoleName)
		roleDefinitionId: storageAccountModule.outputs.storageRoleName
		storageAccountName: storageAccountModule.outputs.storageName
	}
}




resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaulName
  scope: resourceGroup(subscription().subscriptionId,kvRgName) 
}

module serverDatabaseforsql 'modules/server-Database-SQL.bicep' = {
	name: 'server-database-deployment'
	params: {
		DbName: databaseName
		env: env
		location: location
		sqlAdministratorLogin: sqlAdminlogin
		sqlAdministratorPassword: keyvault.getSecret('sqlPasswordAdmin')
		webappIp: webApiCreation.outputs.webApiIp
	}
}


module webApiCreation 'modules/application-web-api.bicep' = {
	name: 'web-api-deployment'
	params: {
		branch: branch
		env: env
		location: location
		msiName: managedIdModule.outputs.manPrincipalName
		repoURL: repoUrl
		skuCapacity: skuApiServiceCapacity
		skuName: skuApiServiceName
	}
}


module apiInsights 'modules/insights-analytics-space.bicep' = {
	name: 'appInsight-logspace-deployment'
	params: {
		env: env
		location: location
		webApiName: webApiCreation.outputs.webApiName
	}
}

module appConfiguration 'modules/appservice-setConfiguration.bicep' = {
	name: 'set-configuration-for-api'
	params: {
		webApiName: webApiCreation.outputs.webApiName
		apiConfigSet: apiConf
		// funcAppName: functionApp.outputs.functionName
		// funcAppConfigSet: funAppConf
	}
}


module roleAssignmentForAppInsight 'modules/role-assignmentForAppInsight.bicep' = {
	name: 'role-assignment-insight'
	params: {
		ContributeRoleAssignmentName: guid(apiInsights.outputs.logSpaceId, managedIdModule.outputs.manPrincipalId, apiInsights.outputs.contributeRoleId)
		ContributeRoleDefinitionId: apiInsights.outputs.contributeRoleId
		logSpaceName: apiInsights.outputs.logSpaceName
		principalId: managedIdModule.outputs.manPrincipalId
		ReadRoleAssignmentName: guid(apiInsights.outputs.logSpaceId, managedIdModule.outputs.manPrincipalId, apiInsights.outputs.readRoleId)
		ReadRoleDefinitionId: apiInsights.outputs.readRoleId
	}
}



module serviceBus 'modules/serviceBus-topics.bicep' = {
	name: 'service-bus-deployment'
	params: {
		env: env
		location: location 
	}
}


module roleAssignmentForServiceBus 'modules/role-assignmentForServiceBus.bicep' = {
	name: 'role-assignment-service-bus'
	params: {
		keyVaultName: keyVaultModule.outputs.keyVaultNameOut
		principalId: managedIdModule.outputs.manPrincipalId
		roleDefinitionId: serviceBus.outputs.sbSenderRoleDefinition
		serviceBusId: serviceBus.outputs.serviceBusId
	}
}

module functionApp 'modules/functionApp-integration.bicep' = {
	name: 'function-app-deployment'
	params: {
		env: env
		location: location
		functionaAppName: functionAppName
		storageAccountName: storageAccountModule.outputs.storageName
		bindingName: bindingName
		nameOfContainer: containerName
	}
}

module roleAssignmentForfunctionApp 'modules/role-assignmentForFunctionApp.bicep' = {
	name: 'role-assignment-function-app'
	params: {
		principalId: functionApp.outputs.functionPrincipal
		serviceBusServiceName: serviceBus.outputs.serviceBusName
		storageServiceName: storageAccountModule.outputs.storageName
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


