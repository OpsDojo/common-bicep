// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The resource name of the sql server.')
param sqlServerResourceName string 

@description('The name of the database.')
param databaseName string

@description('Whether to initiate with AdventureWorksLT. Defaults to false.')
param useAdventureWorks bool = false

@description('Whether to use the Free SKU. If false, uses Basic (5 DTU) plan. Defaults to true.')
param useFree bool = true

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
resource mainResource 'Microsoft.Sql/servers/databases@2023-02-01-preview' = {
  name: '${sqlServerResourceName}/${databaseName}'
  location: location
  tags: tags
  sku: {
    name: useFree ? 'Free' : 'Basic'
  }
  properties: {
    sampleName: useAdventureWorks ? 'AdventureWorksLT' : null
  }
}

// -----------------------------------------------------------------------------
// Common Output
// -----------------------------------------------------------------------------
@description('The id of the main resource defined in this template.')
output resourceId string = mainResource.id

@description('The name of the main resource defined in this template.')
output resourceName string = mainResource.name

@description('The connection string for the database.')
output connectionString string = 'Server=tcp:${sqlServerResourceName}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${databaseName};Authentication=Active Directory Default;Connection Timeout=30;'
