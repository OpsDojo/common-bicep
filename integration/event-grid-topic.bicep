// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('Whether the topic is reachable over public network.')
param isPublic bool

@description('If true, only an AAD token will be used to authenticate users publishing to the topic.')
param disableLocalAuth bool

@description('If provided, access is restricted to these ID CIDR ranges only.')
param whitelistedIpCidrs array

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
resource mainResource 'Microsoft.EventGrid/topics@2023-06-01-preview' = {
  name: '${prefix}-evgt-${suffix}'
  location: location
  tags: tags
  properties: {
    disableLocalAuth: disableLocalAuth
    publicNetworkAccess: isPublic ? 'Enabled' : 'Disabled'
    inputSchema: 'EventGridSchema'
    inboundIpRules: [for cidr in whitelistedIpCidrs: {
      action: 'Allow'
      ipMask: cidr
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
