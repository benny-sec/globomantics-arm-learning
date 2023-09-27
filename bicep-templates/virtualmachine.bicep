@description('Enter the password for the admin account on this machine')
@secure()
param adminPassword string

@description('Enter the admin username')
@secure()
param adminUsername string

@description('Enter the location to deploy the resource to')
param location string

resource ubuntuVM1_nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'ubuntuVM1-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'nsgRule1'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource ubuntuVM1_VirtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: 'ubuntuVM1-VirtualNetwork'
  location: location
  tags: {
    displayName: 'ubuntuVM1-VirtualNetwork'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'ubuntuVM1-VirtualNetwork-Subnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: ubuntuVM1_nsg.id
          }
        }
      }
    ]
  }
}

resource ubuntuVM1_NetworkInterface 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: 'ubuntuVM1-NetworkInterface'
  location: location
  tags: {
    displayName: 'ubuntuVM1-NetworkInterface'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'ubuntuVM1-VirtualNetwork', 'ubuntuVM1-VirtualNetwork-Subnet')
          }
        }
      }
    ]
  }
  dependsOn: [
    ubuntuVM1_VirtualNetwork
  ]
}

resource ubuntuVM1 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: 'ubuntuVM1'
  location: location
  tags: {
    displayName: 'ubuntuVM1'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: 'ubuntuVM1'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '16.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: 'ubuntuVM1-OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: ubuntuVM1_NetworkInterface.id
        }
      ]
    }
  }
}
