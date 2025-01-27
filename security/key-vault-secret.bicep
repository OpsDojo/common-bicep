// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The resource name of the keyvault.')
param keyVaultResourceName string

@description('The name of the secret.')
param secretName string

@secure()
@description('The value of the secret.')
param secretValue string

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: '${keyVaultResourceName}/${secretName}'
  properties: {
    value: secretValue
  }
}

// -----------------------------------------------------------------------------
// Common Output
// -----------------------------------------------------------------------------
@description('The id of the main resource defined in this template.')
output resourceId string = mainResource.id

@description('The name of the main resource defined in this template.')
output resourceName string = mainResource.name
