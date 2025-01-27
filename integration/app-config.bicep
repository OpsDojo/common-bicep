// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('Whether to only allow AAD authenticated access. Defaults to true.')
param disableLocalAccess bool = true

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
// Variables
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: '${prefix}-appconfig-${suffix}'
  location: location
  tags: tags
  sku: {
    name: 'Free'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: disableLocalAccess
    encryption: {
      // keyVaultProperties: Not available on free tier :'(
    }
  }
}

// -----------------------------------------------------------------------------
// Common Output
// -----------------------------------------------------------------------------
@description('The id of the main resource defined in this template.')
output resourceId string = mainResource.id

@description('The name of the main resource defined in this template.')
output resourceName string = mainResource.name

@description('The service principal (object) id of the main resource defined in this template.')
output resourcePrincipalId string = mainResource.identity.principalId

// -----------------------------------------------------------------------------
// Specific Output
// -----------------------------------------------------------------------------

@description('The endpoint of the app config resource.')
output endpoint string = mainResource.properties.endpoint
