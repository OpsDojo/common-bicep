// -----------------------------------------------------------------------------
// Common Parameters
// -----------------------------------------------------------------------------
@description('NB: THIS TEMPLATE IS CURRENTLY NOT SUPPORTED FOR IAC DEPLOYMENTS. A globally-unique tenant subdomain, <SUBDOMAIN>.onmicrosoft.com.')
param subdomain string

@description('The display name. If no value is provided, the subdomain is used.')
param displayName string = subdomain

@description('The resource location. Currently one of: global, unitedstates, europe, asiapacific, australia, japan.')
@minLength(3)
param location string = 'Europe'

@description('Two-letter codes as listed here: https://aka.ms/B2CDataResidency.')
@minLength(2)
@maxLength(2)
param countryCode string = 'GB'

@description('The resource tags.')
param tags object

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.AzureActiveDirectory/b2cDirectories@2023-01-18-preview' = {
  name: '${subdomain}.onmicrosoft.com'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'A0'
  }
  properties: {
    createTenantProperties: {
      countryCode: countryCode
      displayName: displayName
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

// -----------------------------------------------------------------------------
// Specific Output
// -----------------------------------------------------------------------------
@description('The id of the tenant.')
output tenantId string = mainResource.properties.tenantId
