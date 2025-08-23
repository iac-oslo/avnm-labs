param parIndex int = 1
param parLocation string = 'westeurope'
param numberOfIpAddresses int = 30

var varVNetName = 'vnet-online${parIndex}-${parLocation}'

resource ipamPool  'Microsoft.Network/networkManagers/ipamPools@2024-07-01' existing = {
  name: 'vnm-${parLocation}-avnm-labs/iac-main'
}

module modVNet 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'deploy-${varVNetName}-${parIndex}'
  params: {
    addressPrefixes: [
      ipamPool.id
    ]
    ipamPoolNumberOfIpAddresses: '${numberOfIpAddresses}'
    name: varVNetName
    location: parLocation
    subnets: [
      {
        name: 'subnet-workload'
        ipamPoolPrefixAllocations: [
          {
            pool: {
              id: ipamPool.id
            }
            numberOfIpAddresses: '${numberOfIpAddresses}'
          }
        ]
      }
    ]
    enableTelemetry: false
  }
}
