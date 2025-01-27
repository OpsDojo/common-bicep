// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The (object) id of the service principal requiring access.')
param principalId string

@description('The role to assign.')
@allowed([
  'acrpull'
  'acrpush'
  'contributor'
  'Storage Blob Data Contributor'
  'App Configuration Data Owner'
  'App Configuration Data Reader'
])
param role string

@description('The principal type. Defaults to service principal.')
@allowed([
  'ServicePrincipal'
  'Group'
])
param principalType string = 'ServicePrincipal'

// -----------------------------------------------------------------------------
// Variables
// -----------------------------------------------------------------------------
@description('See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for more info.')
var roles = {
  acrpush: '8311e382-0749-4cb8-b61a-304f252e45ec'
  acrpull: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
  contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  'Storage Blob Data Contributor': 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  'App Configuration Data Owner': '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b'
  'App Configuration Data Reader': '516239f1-63e1-4d78-a4de-a74fb236a071' 
}

var roleId = roles[role]

// -----------------------------------------------------------------------------
// Ensure role definition exists
// -----------------------------------------------------------------------------
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: roleId
}

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, roleId)
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: roleDefinition.id
  }
}

// -----------------------------------------------------------------------------
// Common Output
// -----------------------------------------------------------------------------
@description('The id of the main resource defined in this template.')
output resourceId string = mainResource.id

@description('The name of the main resource defined in this template.')
output resourceName string = mainResource.name
