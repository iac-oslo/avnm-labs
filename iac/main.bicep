targetScope = 'subscription'
param location string
param subscriptionId string = subscription().id  // change this to your subscription ID if needed

import { getResourcePrefix, hubAddressRange, adminUsername, adminPassword } from 'variables.bicep'

var resourcePrefix = getResourcePrefix(location)
var resourceGroupName = 'rg-${resourcePrefix}'
module rg 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'deploy-${resourceGroupName}'
  params: {
    name: resourceGroupName
    tags: {
      Environment: 'IaC'
    }
  }
}

module workspace 'br/public:avm/res/operational-insights/workspace:0.12.0' = {
  name: 'deploy-law'
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
  params: {
    name: 'law-${resourcePrefix}'
    location: location
  }
}

module networkManager 'br/public:avm/res/network/network-manager:0.5.2' = {
  name: 'deploy-vnm-${resourcePrefix}'
  dependsOn: [
    rg
  ]
  scope: resourceGroup(resourceGroupName)  
  params: {
    name: 'vnm-${resourcePrefix}'
    networkManagerScopes: {
      subscriptions: [
        subscriptionId
      ]
    }
    networkManagerScopeAccesses: [
      'SecurityAdmin'
      'Connectivity'
      'Routing'
    ]    
  }
}

module hub 'modules/hub.bicep' = {
  name: 'deploy-hub-${resourcePrefix}'
  scope: resourceGroup(resourceGroupName)
  params: {
    parLocation: location
    parAddressRange: hubAddressRange
    parWorkspaceResourceId: workspace.outputs.resourceId    
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

module spokes 'modules/spoke.bicep' = [for i in range(1, 2): {
  name: 'deploy-spoke${i}-${resourcePrefix}'
  scope: resourceGroup(resourceGroupName)
  params: {
    parIndex: i
    parLocation: location
    parAddressRange: '10.9.${i}.0/24'
    parWorkspaceResourceId: workspace.outputs.resourceId    
    adminUsername: adminUsername
    adminPassword: adminPassword
  }  
}]

