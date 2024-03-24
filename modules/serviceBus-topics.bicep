param location string 

param env string

var sbNameSpace = 'service-bus-namespace-${env}-${location}'

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: sbNameSpace
  location: location
  sku: {
    name: 'Standard'
    tier:'Standard'
  }
}



var sbTopics = '${sbNameSpace}-topics'
resource serviceBusTopics 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  name: sbTopics
  parent: serviceBus
  properties:{
    requiresDuplicateDetection: true
    enablePartitioning: true
    enableBatchedOperations: true
  }
}


resource serviceBusSenderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope:subscription()
  name: '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'
}


resource serviceBusListenRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
}

output serviceBusName string = serviceBus.name
output serviceBusTopicName string = serviceBusTopics.name
output serviceBusId string = serviceBus.id


output sbListenRoleDefinition string = serviceBusListenRoleDefinition.id
output sbSenderRoleDefinition string = serviceBusSenderRoleDefinition.id
