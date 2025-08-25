param spoke1IPRange string = '10.9.1.0/24'
param spoke2IPRange string = '10.9.2.0/24'


resource firewallPolicies 'Microsoft.Network/firewallPolicies@2024-07-01' existing = {
  name: 'nfp-westeurope'
}

resource spokesRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-05-01' = {
  parent: firewallPolicies
  name: 'SpokesFirewallRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
      {
            name: 'allow-ping-between-spokes'
            ruleType: 'NetworkRule'
            description: 'Allow ICMP between spoke VNets'
            sourceAddresses: [
              spoke1IPRange
              spoke2IPRange
            ]
            ipProtocols: [
              'ICMP'
            ]
            destinationPorts: [
              '*'
            ]
            destinationAddresses: [
              spoke1IPRange
              spoke2IPRange
            ]
          }          
        ]
      }
    ]
  }
}
