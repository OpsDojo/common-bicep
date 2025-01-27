// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('A short name to include in the resource name prepended to suffix. An empty string may be passed for the resource group\'s "main" app. But all apps must have a unique value within a particular resource group.')
param shortName string

@description('The resource id of the hosting app service plan.')
param appServicePlanId string

@description('The runtime identifier.')
param runtimeIdent string = 'DOTNETCORE:8.0'

@description('The path to use for health check. Defaults to "/health".')
param healthCheckPath string = '/health'

@description('Format: [{ name:, value: }, ...]')
param appSettings array = []

@description('Format: [{ name:, value: }, ...]')
param connectionStrings array = []

@description('Whether or not this is a function app. Defaults to false.')
param isFunctionApp bool = false

@description('Whether or not a client certificate is required. Defaults to false.')
param requireCert bool = false

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
@description('Mapped connection strings.')
var mappedConnections = map(range(0, length(connectionStrings)), i => {
  name: connectionStrings[i].name
  connectionString: connectionStrings[i].value
  type: 'Custom'
})

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.Web/sites@2022-09-01' = {
  name: '${prefix}-app-${toLower(shortName)}${suffix}'
  location: location
  tags: tags
  kind: isFunctionApp ? 'functionapp,linux' : 'linuxapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    reserved: true
    httpsOnly: true
    clientCertEnabled: requireCert
    clientCertMode: requireCert ? 'Required' : 'Optional'
    siteConfig: {
      logsDirectorySizeLimit: 25
      httpLoggingEnabled: true
      appSettings: concat(appSettings, [
        { name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS', value: 5 }
      ])
      connectionStrings: mappedConnections
      ftpsState: 'Disabled'
      linuxFxVersion: runtimeIdent
      minTlsVersion: '1.2'
      healthCheckPath: empty(healthCheckPath) ? null : healthCheckPath
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
@description('The application base url.')
output appUrl string = 'https://${mainResource.properties.defaultHostName}'
