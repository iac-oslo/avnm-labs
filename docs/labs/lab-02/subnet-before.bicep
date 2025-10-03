param parIndex int = 1
param parLocation string = 'westeurope'

var varVNetName = 'vnet-online${parIndex}-${parLocation}'

resource vNet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: varVNetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  parent: vNet
  name: 'subnet-workload'
  properties: {
    addressPrefixes: [
      '10.9.5.0/27'
    ]
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

// az deployment group create -g rg-westeurope-avnm-labs --template-file subnet-before.bicep
