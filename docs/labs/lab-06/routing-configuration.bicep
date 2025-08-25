param azureFirewallPrivateIp string = '10.9.0.4'
param spoke2VNetIPRange string = '10.9.2.0/24'
param spoke1VNetIPRange string = '10.9.1.0/24'

resource networkManager 'Microsoft.Network/networkManagers@2024-07-01' existing = {
  name: 'vnm-westeurope-avnm-labs'
}

resource routingConfiguration 'Microsoft.Network/networkManagers/routingConfigurations@2024-05-01' = {
  parent: networkManager
  name: 'rc-westeurope'
  properties: {
  }
}

resource ng_spokes_westeurope 'Microsoft.Network/networkManagers/networkGroups@2024-07-01' existing = {
  parent: networkManager
  name: 'ng-spokes-westeurope'
}

resource ruleCollection 'Microsoft.Network/networkManagers/routingConfigurations/ruleCollections@2024-05-01' = {
  parent: routingConfiguration
  name: 'spokes'
  properties: {
    appliesTo: [
      {
        networkGroupId: ng_spokes_westeurope.id
      }
    ]
    disableBgpRoutePropagation: 'True'
  }
}

resource internet 'Microsoft.Network/networkManagers/routingConfigurations/ruleCollections/rules@2024-05-01' = {
  parent: ruleCollection
  name: 'internet'
  properties: {
    destination: {
      type: 'AddressPrefix'
      destinationAddress: '0.0.0.0/0'
    }
    nextHop: {
      nextHopType: 'VirtualAppliance'
      nextHopAddress: azureFirewallPrivateIp
    }
  }
}

resource spoke2 'Microsoft.Network/networkManagers/routingConfigurations/ruleCollections/rules@2024-05-01' = {
  parent: ruleCollection
  name: 'spoke2'
  properties: {
    destination: {
      type: 'AddressPrefix'
      destinationAddress: spoke2VNetIPRange
    }
    nextHop: {
      nextHopType: 'VirtualAppliance'
      nextHopAddress: azureFirewallPrivateIp
    }
  }
}

resource spoke1 'Microsoft.Network/networkManagers/routingConfigurations/ruleCollections/rules@2024-05-01' = {
  parent: ruleCollection
  name: 'spoke1'
  properties: {
    destination: {
      type: 'AddressPrefix'
      destinationAddress: spoke1VNetIPRange
    }
    nextHop: {
      nextHopType: 'VirtualAppliance'
      nextHopAddress: azureFirewallPrivateIp
    }
  }
}
