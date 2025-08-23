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
        addressPrefixes: [cidrSubnet(parAddressRange, 26, 0)]
      }
      {
        name: 'AzureBastionSubnet'
        addressPrefixes: [cidrSubnet(parAddressRange, 26, 1)]
      }
      {
        name: 'subnet-workload'
        addressPrefixes: [cidrSubnet(parAddressRange, 26, 2)] 
      }
      {
        name: 'AzureFirewallManagementSubnet'
        addressPrefixes: [cidrSubnet(parAddressRange, 26, 3)] 
      }
    ]
    enableTelemetry: false
  }
}

module publicIP 'br/public:avm/res/network/public-ip-address:0.9.0' = {
  name: 'deploy-public-ip'
  params: {
    name: 'pip-bastion-${parLocation}'
    location: parLocation
    skuName: 'Standard'
    availabilityZones: []
  }
}

resource resBastion 'Microsoft.Network/bastionHosts@2024-07-01' = {
  name: 'bastion-${parLocation}'
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    enableTunneling: true
    enableIpConnect: false
    disableCopyPaste: false
    enableShareableLink: false
    enableKerberos: false
    enableSessionRecording: false
    ipConfigurations: [
      {
        name: 'IpConfAzureBastionSubnet'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.outputs.resourceId
          }
          subnet: {
            id: '${modVNet.outputs.resourceId}/subnets/AzureBastionSubnet'
          }
        }
      }
    ]
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

module firewallPolicy 'br/public:avm/res/network/firewall-policy:0.3.1' = {
  name: 'firewallPolicyDeployment'
  params: {
    name: 'nfp-${parLocation}'
    tier: 'Basic'
    threatIntelMode: 'Off'
  }
}

var nafName = 'naf-${parLocation}'
module azureFirewall 'br/public:avm/res/network/azure-firewall:0.8.0' = {
  name: 'deploy-azure-firewall-basic'
  params: {
    name: nafName
    azureSkuTier: 'Basic'
    location: parLocation
    virtualNetworkResourceId: modVNet.outputs.resourceId
    firewallPolicyId: firewallPolicy.outputs.resourceId
    publicIPAddressObject: {
      name: 'pip-${nafName}'
      publicIPAllocationMethod: 'Static'
      skuName: 'Standard'
      skuTier: 'Regional'
    }    
    diagnosticSettings: [
      {
        name: 'diagnostics'
        workspaceResourceId: parWorkspaceResourceId
        logAnalyticsDestinationType: 'Dedicated'
        logCategoriesAndGroups: [
          {
            categoryGroup: 'allLogs'
            enabled: true
          }
        ]
      }
    ]
  }
}
