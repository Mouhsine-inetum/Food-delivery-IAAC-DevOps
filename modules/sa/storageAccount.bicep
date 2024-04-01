
@description('Specifies the Azure location where the resources should be created.')
param location string

@description('the different names of the containers')
param containerNames array= [
	'logs'
	'foodelivery-products'
]

@description('component name used for resource name')
param partName string 

param tags object

var nameSa = 'sa${toLower(replace(partName,'-',''))}'


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01'={
	name: nameSa
	location: location
	tags:tags
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
