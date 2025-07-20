targetScope = 'resourceGroup'

param parLocation string
param parAddressRange string
param parWorkspaceResourceId string
param adminUsername string
@secure()
param adminPassword string

var varVNetName = 'vnet-hub-${parLocation}'


module modVNet 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'deploy-${varVNetName}'
  params: {
    addressPrefixes: [
      parAddressRange
    ]
    name: varVNetName
    diagnosticSettings: [
      {
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'diagnostic'
        workspaceResourceId: parWorkspaceResourceId
      }
    ]
    location: parLocation
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: cidrSubnet(parAddressRange, 26, 0)
      }
      {
        name: 'AzureBastionSubnet'
        addressPrefix: cidrSubnet(parAddressRange, 26, 1)
      }
      {
        name: 'subnet-workload'
        addressPrefix: cidrSubnet(parAddressRange, 26, 2)
      }
    ]
    enableTelemetry: false
  }
}

module bastionHost 'br/public:avm/res/network/bastion-host:0.7.0' = {
  name: 'deploy-bastion-Host'
  params: {
    name: 'bastion-${parLocation}'
    virtualNetworkResourceId: modVNet.outputs.resourceId
    location: parLocation
    skuName: 'Developer'
  }
}

module modVirtualMachine 'br/public:avm/res/compute/virtual-machine:0.16.0' = {
  name: 'deploy-hub-vm-${parLocation}'
  params: {
    adminUsername: adminUsername
    adminPassword: adminPassword
    imageReference: {
      offer: '0001-com-ubuntu-server-jammy'
      publisher: 'Canonical'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
    name: 'vm-hub-${parLocation}'
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetResourceId: modVNet.outputs.subnetResourceIds[2]
          }
        ]
        nicSuffix: '-nic-01'
        enableAcceleratedNetworking: false
      }
    ]
    osDisk: {
      caching: 'ReadWrite'
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'Standard_LRS'
      }
    }
    osType: 'Linux'
    vmSize: 'Standard_B1s'
    availabilityZone: -1
    location: parLocation
    enableTelemetry: false
  }
}
