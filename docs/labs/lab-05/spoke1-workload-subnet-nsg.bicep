param hubVmIP string = '10.9.0.132'

resource nsg_workload_subnet_spoke1_westeurope 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: 'nsg-workload-subnet-spoke1-westeurope'
  location: 'westeurope'
  properties: {
    securityRules: [
      {
        name: 'deny-ssh-from-hub-vm'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: hubVmIP
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}
