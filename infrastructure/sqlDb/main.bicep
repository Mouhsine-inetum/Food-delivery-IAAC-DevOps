param partName string 
param location string
param sqlAdminLogin string 
param kvName string
param rgKvName string
//tag infos
param owner string
param costCenter string
param application string
param descp string
param repo string
param version string

var webApiName = 'wa-${partName}'
var tag = {
  owner: owner
  costCenter: costCenter
  application: application
  descp: descp
  repo: repo
  version : version
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: kvName
  scope: resourceGroup(subscription().subscriptionId,rgKvName) 
}

resource webApiCreated 'Microsoft.Web/sites@2023-01-01' existing = {
  name: webApiName
}
module serverDatabaseforsql '../../modules/sqlDB/server-Database-SQL.bicep' = {
	name: 'server-database-deployment'
	params: {
		location: location
		sqlAdministratorLogin: sqlAdminLogin
		sqlAdministratorPassword: keyvault.getSecret('sqlPasswordAdmin')
		webappIp: split(webApiCreated.properties.outboundIpAddresses,',')
		partName: partName
	}
}
