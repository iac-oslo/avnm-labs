resource ipamPool'Microsoft.Network/networkManagers/ipamPools@2024-07-01' existing = {
  name: 'vnm-norwayeast-avnm-labs/iac-main'
}

resource vwanAlocation 'Microsoft.Network/networkManagers/ipamPools/staticCidrs@2024-07-01' = {
  name: 'VWAN-hub'
  parent: ipamPool
  properties: {
    addressPrefixes: [
      '10.9.4.0/23'
    ]         
  }
}

resource onpremAllocation 'Microsoft.Network/networkManagers/ipamPools/staticCidrs@2024-07-01' = {
  name: 'OnPrem'
  parent: ipamPool
  properties: {
    addressPrefixes: [
      '10.9.250.0/23'
      '10.9.252.0/23'
      '10.9.254.0/23'
    ]         
  }
}
