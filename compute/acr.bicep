// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('Whether the registry is private. Defaults to true.')
param private bool = true

@allowed(['Basic', 'Standard'])
@description('The sku / pricing tier. Defaults to Basic.')
param sku string = 'Basic'

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
resource mainResource 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' = {
  name: replace('${prefix}-acr-${suffix}', '-', '')
  location: location
  tags: tags
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    networkRuleBypassOptions: 'AzureServices'
    publicNetworkAccess: private ? 'Disabled' : 'Enabled'
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
