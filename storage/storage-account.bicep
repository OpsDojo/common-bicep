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
resource mainResource 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${prefix}stg${replace(suffix, '-', '')}'
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
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
var storageAccountKeys = mainResource.listKeys().keys
var endpointSuffix = environment().suffixes.storage
var connectionPrefix = 'DefaultEndpointsProtocol=https;AccountName=${mainResource.name}'

@description('The main storage connection string.')
output primaryConnection string = '${connectionPrefix};AccountKey=${storageAccountKeys[0].value};EndpointSuffix=${endpointSuffix}'

@description('An alternative storage connection string.')
output secondaryConnection string = '${connectionPrefix};AccountKey=${storageAccountKeys[1].value};EndpointSuffix=${endpointSuffix}'
