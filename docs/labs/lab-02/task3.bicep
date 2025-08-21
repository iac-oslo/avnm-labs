param parIndex int = 1
param parLocation string = 'norwayeast'

var varVNetName = 'vnet-spoke${parIndex}-${parLocation}'

resource ipamPool  'Microsoft.Network/networkManagers/ipamPools@2024-07-01' existing = {
  name: 'vnm-${parLocation}-avnm-labs/iac-main'
}

module modVNet 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'deploy-${varVNetName}-${parIndex}'
  params: {
    addressPrefixes: [
      ipamPool.id
    ]
    ipamPoolNumberOfIpAddresses: '256'
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
            numberOfIpAddresses: '256'
          }
        ]
      }
    ]
    enableTelemetry: false
  }
}
