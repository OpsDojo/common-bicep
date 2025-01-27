// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('Whether to use the free tier. Only 1x allowed per subscription, and obviously no SLA.')
param useFreeTier bool

@description('Flag to indicate whether or not this region is an AvailabilityZone region')
param isZoneRedundant bool

@description('Whether to enable serverless cosmos.')
param isServerless bool

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
resource mainResource 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' = {
  name: '${prefix}-cosmos-${suffix}'
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    enableFreeTier: useFreeTier
    enableAutomaticFailover: false
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 1440
        backupRetentionIntervalInHours: 48
      }
    }
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        isZoneRedundant: isZoneRedundant
      }
    ]
    capabilities: !isServerless ? null : [
      {
        name: 'EnableServerless'
      }
    ]
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
var cosmosConn = mainResource.listConnectionStrings().connectionStrings[0].connectionString
@description('The primary connection string of the cosmos account.')
output cosmosConnection string = cosmosConn
