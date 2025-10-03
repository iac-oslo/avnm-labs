param parIndex int = 2
param parLocation string = 'westeurope'

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
    ipamPoolNumberOfIpAddresses: '200'
    name: varVNetName
    location: parLocation
    subnets: [
      {
        name: 'subnet-workload-1'
        ipamPoolPrefixAllocations: [
          {
            pool: {
              id: ipamPool.id
            }
            numberOfIpAddresses: '50'
          }
        ]
      }
      {
        name: 'subnet-workload-2'
        ipamPoolPrefixAllocations: [
          {
            pool: {
              id: ipamPool.id
            }
            numberOfIpAddresses: '50'
          }
        ]
      }
      {
        name: 'subnet-workload-3'
        ipamPoolPrefixAllocations: [
          {
            pool: {
              id: ipamPool.id
            }
            numberOfIpAddresses: '80'
          }
        ]
      }

    ]
    enableTelemetry: false
  }
}
