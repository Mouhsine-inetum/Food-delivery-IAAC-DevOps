
@description('Specifies the Azure location where the resources should be created.')
param location string

param env string

@description('the different names of the containers')
param containerNames array= [
	'${env}-blob-log'
	'${env}-foodelivery-products'
]


var nameSa='${env}safrombicep${location}'


var readRoleId ='2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
@description('This is the built-in storage blob reader role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource storageBlobReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: readRoleId
}


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01'={
	name: nameSa
	location: location
	sku: {
		name:'Standard_LRS'
	}
	kind: 'StorageV2'
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = if (!empty(containerNames)) {
	name: 'default'
	parent: storageAccount
	properties: {
		isVersioningEnabled: true
	}
}

// resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
// 	name: nameBlob
// 	parent:blobServices
// 	properties : {
// 	publicAccess:'None'
// 	}
// }

resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for item in containerNames: {
	name:item
	parent:blobServices
	properties:{
	publicAccess:'None'
	}
}]



output storageName string = storageAccount.name
output idStorage string = storageAccount.id
output storageRoleName string = storageBlobReaderRoleDefinition.id
