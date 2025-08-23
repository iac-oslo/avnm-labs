resource networkManager 'Microsoft.Network/networkManagers@2024-07-01' existing = {
  name: 'vnm-westeurope-avnm-labs'
}

resource securityAdminConfiguration 'Microsoft.Network/networkManagers/securityAdminConfigurations@2024-07-01' = {
  parent: networkManager
  name: 'sc-westeurope'
  properties: {
    applyOnNetworkIntentPolicyBasedServices: []
    networkGroupAddressSpaceAggregationOption: 'None'
  }
}

resource ng_hub_westeurope 'Microsoft.Network/networkManagers/networkGroups@2024-07-01' existing = {
  parent: networkManager
  name: 'ng-hub-westeurope'
}

resource ng_online_westeurope 'Microsoft.Network/networkManagers/networkGroups@2024-07-01' existing = {
  parent: networkManager
  name: 'ng-online-westeurope'
}

resource ng_spokes_westeurope 'Microsoft.Network/networkManagers/networkGroups@2024-07-01' existing = {
  parent: networkManager
  name: 'ng-spokes-westeurope'
}

resource ruleCollection 'Microsoft.Network/networkManagers/securityAdminConfigurations/ruleCollections@2024-07-01' = {
  parent: securityAdminConfiguration
  name: 'default'
  properties: {
    appliesToGroups: [
      {
        networkGroupId: ng_hub_westeurope.id
      }
      {
        networkGroupId: ng_online_westeurope.id
      }
      {
        networkGroupId: ng_spokes_westeurope.id
      }
    ]
  }  
}

resource allow_outbound_ifconfig_me 'Microsoft.Network/networkManagers/securityAdminConfigurations/ruleCollections/rules@2024-07-01' = {
  parent: ruleCollection
  name: 'allow-outbound-ifconfig-me'
  kind: 'Custom'
  properties: {
    priority: 18
    direction: 'Outbound'
    access: 'Allow'
    sources: [
      {
        addressPrefix: '*'
        addressPrefixType: 'IPPrefix'
      }
    ]
    destinations: [
      {
        addressPrefix: '34.160.111.145'
        addressPrefixType: 'IPPrefix'
      }
    ]
    destinationPortRanges: [
      '80'
      '443'
    ]
    protocol: 'Tcp'
  }
}

resource allow_ssh_from_hub 'Microsoft.Network/networkManagers/securityAdminConfigurations/ruleCollections/rules@2024-07-01' = {
  parent: ruleCollection
  name: 'allow-ssh-from-hub'
  kind: 'Custom'
  properties: {
    priority: 8
    direction: 'Inbound'
    access: 'Allow'
    sources: [
      {
        addressPrefix: '10.9.0.132'
        addressPrefixType: 'IPPrefix'
      }
    ]
    destinations: [
      {
        addressPrefix: '*'
        addressPrefixType: 'IPPrefix'
      }
    ]
    destinationPortRanges: [
      '22'
    ]
    protocol: 'Tcp'
  }
}

resource allow_ssh_to_hub 'Microsoft.Network/networkManagers/securityAdminConfigurations/ruleCollections/rules@2024-07-01' = {
  parent: ruleCollection
  name: 'allow-ssh-to-hub'
  kind: 'Custom'
  properties: {
    priority: 6
    direction: 'Inbound'
    access: 'Allow'
    sources: [
      {
        addressPrefix: '*'
        addressPrefixType: 'IPPrefix'
      }
    ]
    destinations: [
      {
        addressPrefix: '10.9.0.132'
        addressPrefixType: 'IPPrefix'
      }
    ]
    destinationPortRanges: [
      '22'
    ]
    protocol: 'Tcp'
  }
}

resource deny_outbound_internet 'Microsoft.Network/networkManagers/securityAdminConfigurations/ruleCollections/rules@2024-07-01' = {
  parent: ruleCollection
  name: 'deny-outbound-internet'
  kind: 'Custom'
  properties: {
    priority: 20
    direction: 'Outbound'
    access: 'Deny'
    sources: [
      {
        addressPrefix: '*'
        addressPrefixType: 'IPPrefix'
      }
    ]
    destinations: [
      {
        addressPrefix: 'Internet'
        addressPrefixType: 'ServiceTag'
      }
    ]
    destinationPortRanges: [
      '80'
      '443'
    ]
    protocol: 'Tcp'
  }
}
resource deny_ssh_and_rdp 'Microsoft.Network/networkManagers/securityAdminConfigurations/ruleCollections/rules@2024-07-01' = {
  parent: ruleCollection
  name: 'deny-ssh-and-rdp'
  kind: 'Custom'
  properties: {
    priority: 10
    direction: 'Inbound'
    access: 'Deny'
    sources: [
      {
        addressPrefix: '*'
        addressPrefixType: 'IPPrefix'
      }
    ]
    destinations: [
      {
        addressPrefix: '*'
        addressPrefixType: 'IPPrefix'
      }
    ]
    destinationPortRanges: [
      '22'
      '3389'
    ]
    protocol: 'Tcp'
  }
}
