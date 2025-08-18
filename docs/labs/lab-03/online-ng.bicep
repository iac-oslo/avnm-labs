resource networkManager 'Microsoft.Network/networkManagers@2024-07-01' existing = {
  name: 'vnm-norwayeast-avnm-labs'
}

resource onlineNetworkGroup 'Microsoft.Network/networkManagers/networkGroups@2024-07-01' = {
  parent: networkManager
  name: 'ng-online'
  properties: {
    description: 'Virtual Networks for Online workloads'
    memberType: 'VirtualNetwork'
  }
}

resource onlineVNet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: 'vnet-online1-norwayeast'
}


resource onlineVNetMember 'Microsoft.Network/networkManagers/networkGroups/staticMembers@2024-07-01' = {
  name: 'static-vnet-online1-norwayeast'
  parent: onlineNetworkGroup
  properties: {
    resourceId: onlineVNet.id
  }
}
