// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The resource name of the parent cosmos account.')
param cosmosAccountResourceName string

@description('The name of the database to provision.')
param databaseName string

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
resource mainResource 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-09-15' = {
  name: '${cosmosAccountResourceName}/${databaseName}'
  location: location
  tags: tags
  properties: {
    resource: {
      id: databaseName
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
