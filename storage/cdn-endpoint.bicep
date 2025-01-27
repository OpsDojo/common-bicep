// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The resource name of the parent CDN.')
param cdnProfileResourceName string

@description('The subdomain of the CDN endpoint.')
param cdnSubdomain string

@description('The name of the storage container.')
param sourceContainerName string

@description('The general location of the CDN. Defaults to westeurope.')
param cdnLocation string = 'westeurope'

@description('The (comma-separated) origins to allow for CORS on the CDN.')
param corsOrigins string

// -----------------------------------------------------------------------------
// Common Parameters
// -----------------------------------------------------------------------------
@description('The resource tags.')
param tags object

// -----------------------------------------------------------------------------
// Parent Resource
// -----------------------------------------------------------------------------
resource existingCdnProfile 'Microsoft.Cdn/profiles@2023-07-01-preview' existing = {
  name: cdnProfileResourceName
}

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.Cdn/profiles/endpoints@2023-07-01-preview' = {
  parent: existingCdnProfile
  name: cdnSubdomain
  location: cdnLocation
  tags: tags
  properties: {
    originHostHeader: '${sourceContainerName}.blob.${environment().suffixes.storage}'
    origins: [
      {
        name: sourceContainerName
        properties: {
          hostName: '${sourceContainerName}.blob.${environment().suffixes.storage}'
          httpPort: 80
          httpsPort: 443
        }
      }
    ]
    deliveryPolicy: {
      description: 'Cors Policy'
      rules: [
        {
          name: 'Global'
          order: 0
          actions: [
            {
              name: 'ModifyResponseHeader'
              parameters: {
                headerAction: 'Overwrite'
                headerName: 'Access-Control-Allow-Origin'
                value: corsOrigins
                typeName: 'DeliveryRuleHeaderActionParameters'
              }
            }
            {
              name: 'ModifyResponseHeader'
              parameters: {
                headerAction: 'Overwrite'
                headerName: 'Access-Control-Allow-Headers'
                value: '*'
                typeName: 'DeliveryRuleHeaderActionParameters'
              }
            }
            {
              name: 'ModifyResponseHeader'
              parameters: {
                headerAction: 'Overwrite'
                headerName: 'Access-Control-Allow-Methods'
                value: '*'
                typeName: 'DeliveryRuleHeaderActionParameters'
              }
            }
          ]
        }
      ]
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
