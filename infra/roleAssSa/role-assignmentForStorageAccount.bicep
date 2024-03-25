@description('the principal id, allows to connect on behalf of the user')
param principalId string

@description('component name used for resource name')
param partName string 


var storageAccountName = 'sa${replace(partName,'-','')}'

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
	name: storageAccountName
}

var readRoleId ='2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
@description('This is the built-in storage blob reader role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource storageBlobReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: readRoleId
}

var roleAssignmentName = guid(storage.id, principalId, storageBlobReaderRoleDefinition.id)


resource roleAssignmentForStorageAccount 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
	name: roleAssignmentName
	scope:storage
	properties: {
		principalId: principalId
		roleDefinitionId: storageBlobReaderRoleDefinition.id
	}
}
