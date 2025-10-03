param parIndex int = 1
param parLocation string = 'westeurope'

var varVNetName = 'vnet-online${parIndex}-${parLocation}'

resource spoke1VNet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: varVNetName
  location: 'westeurope'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.9.5.0/24'
      ]
    }
    privateEndpointVNetPolicies: 'Disabled'
    enableDdosProtection: false
  }
}

// az deployment group create -g rg-westeurope-avnm-labs --template-file vnet-before.bicep
