// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The resource name of an existing cosmos SQL database.')
param cosmosSqlDbResourceName string

@description('The name of the container to provision.')
param containerName string

@description('The partition keys to set up. Format: [ string, string, ... ].')
param partitionKeys array

@description('The unique keys to set up. Format: [ string, string, ... ].')
param uniqueKeys array

// -----------------------------------------------------------------------------
// Common Parameters
// -----------------------------------------------------------------------------
@description('The resource location.')
@minLength(3)
param location string

@description('The resource tags.')
param tags object

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-09-15' = {
  name: '${cosmosSqlDbResourceName}/${containerName}'
  location: location
  tags: tags
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: partitionKeys
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
      }
      uniqueKeyPolicy: empty(uniqueKeys) ? null : {
        uniqueKeys: [
          {
            paths: uniqueKeys
          }
        ]
      }
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
