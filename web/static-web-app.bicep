// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('A short name to include in the resource name prepended to suffix. An empty string may be passed for the resource group\'s "main" app. But all apps must have a unique value within a particular resource group.')
param shortName string

@description('Whether to use Free SKU. Defaults to true.')
param useFreeSku bool = true

@description('A custom domain name for the static web app. (Optional).')
param customDomainName string = ''

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
@description('The SKU name.')
var skuName = useFreeSku ? 'Free' : 'Standard'

@description('Managed service identity configuration.')
var identityConfig = useFreeSku ? null : { type: 'SystemAssigned' }

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.Web/staticSites@2022-09-01' = {
  name: '${prefix}-swa-${toLower(shortName)}${suffix}'
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  identity: identityConfig
  properties: {
    allowConfigFileUpdates: true
    enterpriseGradeCdnStatus: 'Disabled'
    stagingEnvironmentPolicy: 'Enabled'
  }
}

resource customDomainResource 'Microsoft.Web/staticSites/customDomains@2022-09-01' = if(!empty(customDomainName)) {
  parent: mainResource
  name: customDomainName
}

// -----------------------------------------------------------------------------
// Common Output
// -----------------------------------------------------------------------------
@description('The id of the main resource defined in this template.')
output resourceId string = mainResource.id

@description('The name of the main resource defined in this template.')
output resourceName string = mainResource.name

@description('The service principal (object) id of the main resource defined in this template.')
output resourcePrincipalId string = useFreeSku ? '' : mainResource.identity.principalId

// -----------------------------------------------------------------------------
// Specific Output
// -----------------------------------------------------------------------------
@description('The application base url.')
output appUrl string = 'https://${mainResource.properties.defaultHostname}'
