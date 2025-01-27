// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The address range reserved for the network, in CIDR notation.')
param addressPrefixCidr string

@description('A list of subnet short-name-and-CIDR pairs. Format: [{ shortName: string, cidr: string }, ...].')
param subnetShortNamesAndCidrs array

// -----------------------------------------------------------------------------
// Common Parameters
// -----------------------------------------------------------------------------
@description('The environment prefix.')
param prefix string

@description('Amalgam of the workload and the (short) location name.')
@minLength(3)
param suffix string

@description('The resource location.')
@minLength(3)
param location string

@description('The resource tags.')
param tags object

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: '${prefix}-vnet-${suffix}'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixCidr
      ]
    }
    subnets: [for subnet in subnetShortNamesAndCidrs: {
      name: '${prefix}-${toLower(subnet.shortName)}subnet-${suffix}'
      properties: {
        addressPrefix: subnet.cidr
      }
    }]
  }
}

// -----------------------------------------------------------------------------
// Common Output
// -----------------------------------------------------------------------------
@description('The id of the main resource defined in this template.')
output resourceId string = mainResource.id

@description('The name of the main resource defined in this template.')
output resourceName string = mainResource.name

// -----------------------------------------------------------------------------
// Specific Output
// -----------------------------------------------------------------------------
@description('A list of subnets provisioned. Format: [{ shortName, resourceName, resourceId }, ...]')
output subnets array = [for (subnet, i) in subnetShortNamesAndCidrs: {
  shortName: subnet.shortName
  resourceName: mainResource.properties.subnets[i].name
  resourceId: mainResource.properties.subnets[i].id
}]
