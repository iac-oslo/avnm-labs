resource firewallPolicies 'Microsoft.Network/firewallPolicies@2024-07-01' existing = {
  name: 'nfp-westeurope'
}

resource defaultApplicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-07-01' = {
  name: 'DefaultApplicationRuleCollectionGroup'
  parent: firewallPolicies
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: []
        name: 'default-internet-rules'
      }
    ]
  }
}

resource defaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-07-01' = {
  name: 'DefaultNetworkRuleCollectionGroup'
  parent: firewallPolicies
  dependsOn: [
    defaultApplicationRuleCollectionGroup
  ]
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: []
        name: 'spokes-rules'
      }
    ]
  }
}
