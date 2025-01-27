// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('Any secrets to initially provision. Format: [{ name: string, value: string }, ...].')
param secretKvps array

@description('Any RSA 4096 crypto keys. Format: [string, ...]')
param rsaCryptoKeyNames array = []

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
resource mainResource 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: '${prefix}-kyv-${suffix}'
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    accessPolicies: []
    sku: {
      family: 'A'
      name: 'standard'
    }
  }

  resource secret 'secrets' = [for kvp in secretKvps: {
    name: kvp.name
    properties: {
      value: kvp.value
    }
  }]

  resource key 'keys' = [for rsaKeyName in rsaCryptoKeyNames: {
    name: rsaKeyName
    properties: {
      keyOps: [
        'encrypt'
        'decrypt'
      ]
      kty: 'RSA'
      keySize: 4096
    }
  }]
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
@description('The URI of the vault for performing operations on keys and secrets.')
output vaultUri string = mainResource.properties.vaultUri
