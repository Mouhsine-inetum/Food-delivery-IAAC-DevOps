@description('name of the storage to give access to')
param storageAccountName string

@description('the id of the role to assign')
param roleDefinitionId string

@description('the principal id, allows to connect on behalf of the user')
param principalId string


resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
	name: storageAccountName
}

var roleAssignmentName = guid(storage.id, principalId, keyVaultModule.outputs.keyVaultRoleDefinition)


resource roleAssignmentForStorageAccount 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
	name: roleAssignmentName
	scope:storage
	properties: {
		principalId: principalId
		roleDefinitionId: roleDefinitionId
	}
}
