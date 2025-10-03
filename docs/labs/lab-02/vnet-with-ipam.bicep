param parIndex int = 1
param parLocation string = 'westeurope'

var varVNetName = 'vnet-online${parIndex}-${parLocation}'

resource ipamPool 'Microsoft.Network/networkManagers/ipamPools@2024-07-01' existing = {
  name: 'vnm-${parLocation}-avnm-labs/iac-main'
}

resource vNet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: varVNetName
  location: 'westeurope'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.9.5.0/24'
      ]
      ipamPoolPrefixAllocations: [
        {
          numberOfIpAddresses: '256'
          pool: {
            id: ipamPool.id
          }
        }
      ]
    }
    privateEndpointVNetPolicies: 'Disabled'
    enableDdosProtection: false
  }
}

// az deployment group create -g rg-westeurope-avnm-labs --template-file vnet-with-ipam.bicep
