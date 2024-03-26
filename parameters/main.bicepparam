using '../main.bicep'

param env = 'dev'
param keyVaulName = 'kvfoodeliverywesteurope'
param kvRgName = 'cloud-shell-storage-westeurope'
param location = 'westeurope'
param databaseName = 'db-sql-foodelivery'
param sqlAdminlogin = 'adminUser'
param branch = 'main'
param apiConf = [
  {
    name: 'ClientSettings__ClientDomain'
    value: 'https://localhost:44373'
  }
]
param containerName = 'products'
param repoUrl = 'https://github.com/Mouhsine-inetum/Food-delivery-server-alternate.git'
param skuApiServiceCapacity = 3
param skuApiServiceName = 'B1'
param bindingName = 'messages'
param application = ''
param costCenter = ''
param descp = ''
param owner = ''
param repo = ''
param version = 001
param partName = 'ir-Tsg-pfu-we-dev-001'
