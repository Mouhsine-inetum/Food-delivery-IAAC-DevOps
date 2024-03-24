param env string

param location string

@description('the name of the database')
param DbName string

@description('Specifies sql admin login')
@secure()
param sqlAdministratorLogin string



@minLength(8)
@description('password of the admin for the sql server access')
@secure()
param  sqlAdministratorPassword string 


@description('the ip addresses of the web app that will connect to the server')
param webappIp array


var sqlServerName= '${env}-sqlserver-${uniqueString(resourceGroup().id)}-${location}'
var databaseName = '${env}-${DbName}-${location}'




// Data resources
resource sqlserver 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
    version: '12.0'
    // publicNetworkAccess:'Disabled'
  }

  resource database 'databases@2023-05-01-preview' = {
    name: databaseName
    location: location
    sku: {
      name: 'Basic'
    }
    properties: {
      collation: 'SQL_Latin1_General_CP1_CI_AS'
      maxSizeBytes: 1073741824
    }
  }

  resource firewallRule 'firewallRules@2023-05-01-preview' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      endIpAddress: '0.0.0.0'
      startIpAddress: '0.0.0.0'
    }
    
  }



  resource firewallRuleForWebApp 'firewallRules@2023-05-01-preview' = [for (item, index) in webappIp: {
    name:'AllowWebbApp-${index}'
    properties:{
      startIpAddress:item
      endIpAddress:item
    }
  }]

}


