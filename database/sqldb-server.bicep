// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The administrator login.')
param adminLogin string 

@secure()
@description('The administrator password.')
param adminPassword string

@description('Whether to allow all Windows Azure IP addresses. Defaults to true.')
param allowAzureIps bool = true

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
resource mainResource 'Microsoft.Sql/servers@2023-02-01-preview' = {
  name: '${prefix}-sql-${suffix}'
  location: location
  tags: tags
  properties: {
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
  }

  resource azureFirewallRuleResource 'firewallRules' = if (allowAzureIps) {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
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
@description('The fully-qualified domain-name of the database server.')
output fqdn string = mainResource.properties.fullyQualifiedDomainName
