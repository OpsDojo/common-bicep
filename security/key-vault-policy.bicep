// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The name of the key vault to which to apply the policy.')
param keyVaultName string

@description('The AAD (object) id of a user, service principal or security group. A single id must be unique within the policy list.')
@minLength(36)
@maxLength(36)
param permissionsRecipientId string

@description('The permissions to grant for key vault certificates.')
@allowed([
  'all'
  'backup'
  'create'
  'delete'
  'deleteissuers'
  'get'
  'getissuers'
  'import'
  'list'
  'listissuers'
  'managecontacts'
  'manageissuers'
  'purge'
  'recover'
  'restore'
  'setissuers'
  'update'
])
param certificatesPermissions array

@description('The permissions to grant for key vault keys.')
@allowed([
  'all'
  'backup'
  'create'
  'decrypt'
  'delete'
  'encrypt'
  'get'
  'import'
  'list'
  'purge'
  'recover'
  'restore'
  'sign'
  'unwrapKey'
  'update'
  'verify'
  'wrapKey'
])
param keysPermissions array

@description('The permissions to grant for key vault secrets.')
@allowed([
  'all'
  'backup'
  'delete'
  'get'
  'list'
  'purge'
  'recover'
  'restore'
  'set'
])
param secretsPermissions array

@description('The permissions to grant for key vault storage accounts.')
@allowed([
  'all'
  'backup'
  'delete'
  'deletesas'
  'get'
  'getsas'
  'list'
  'listsas'
  'purge'
  'recover'
  'regeneratekey'
  'restore'
  'set'
  'setsas'
  'update'
])
param storagePermissions array

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = {
  name: '${keyVaultName}/replace'
  properties: {
    accessPolicies: [
      {
        objectId: permissionsRecipientId
        tenantId: subscription().tenantId
        permissions: {
          certificates: certificatesPermissions
          keys: keysPermissions
          secrets: secretsPermissions
          storage: storagePermissions
        }
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
