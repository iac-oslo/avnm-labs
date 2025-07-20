targetScope = 'subscription'
param location string = 'norwayeast'
param subscriptionId string = subscription().id  // change this to your subscription ID if needed

import { getResourcePrefix, spoke1AddressRange, hubAddressRange, adminUsername, adminPassword } from 'variables.bicep'

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

// module networkManager 'br/public:avm/res/network/network-manager:0.5.2' = {
//   name: 'deploy-vnm-${resourcePrefix}'
//   scope: resourceGroup(resourceGroupName)  
//   params: {
//     name: 'vnm-${resourcePrefix}'
//     networkManagerScopes: {
//       subscriptions: [
//         subscriptionId
//       ]
//     }
//     networkManagerScopeAccesses: [
//       'SecurityAdmin'
//       'Connectivity'
//       'Routing'
//     ]    
//   }
// }

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

module spoke1 'modules/spoke.bicep' = {
  name: 'deploy-spoke1-${resourcePrefix}'
  scope: resourceGroup(resourceGroupName)
  params: {
    parLocation: location
    parAddressRange: spoke1AddressRange
    parWorkspaceResourceId: workspace.outputs.resourceId    
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}
