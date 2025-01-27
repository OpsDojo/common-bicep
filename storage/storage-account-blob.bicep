// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The resource name of the parent storage account.')
param storageAccountResourceName string

@description('The name of the blob container to provision.')
param containerName string

@description('Whether the blob container may be accessed publicly.')
param publicAccess bool

// -----------------------------------------------------------------------------
// Parent Resource
// -----------------------------------------------------------------------------
resource existingStorageBlobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' existing = {
  name: '${storageAccountResourceName}/default'
}

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: containerName
  parent: existingStorageBlobService
  properties: {
    publicAccess: publicAccess ? 'Container' : 'None'
  }
}

// -----------------------------------------------------------------------------
// Common Output
// -----------------------------------------------------------------------------
@description('The id of the main resource defined in this template.')
output resourceId string = mainResource.id

@description('The name of the main resource defined in this template.')
output resourceName string = mainResource.name
