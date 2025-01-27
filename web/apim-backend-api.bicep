// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The name of the APIM resource.')
param apimResourceName string

@description('The identifier of the API as it appears in APIM.')
param apimApiShortName string

@description('The display name of the API as it appears in APIM.')
param apimApiDisplayName string

@description('The path appended to APIM that routes traffic to the API.')
param apimApiRoutePath string

@description('The API certificate name identifier.')
param apimApiCertName string

@description('The resource name of the source API app service.')
param appServiceResourceName string

@description('The base URL of the source API, as redirected to by APIM.')
param appServiceSourceUrl string

@description('The URI of the key vault URI where the APIM certificates live.')
param keyVaultUri string

// Obtain a reference to the app service
resource appService 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appServiceResourceName
}

@description('The fully-qualified resource URI for the app service instance.')
var appServiceResourceUri = '${environment().resourceManager}${substring(appService.id, 1)}'

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimResourceName

  resource apimCert 'certificates' = {
    name: apimApiCertName
    properties: {
      keyVault: {
        secretIdentifier: '${keyVaultUri}secrets/${apimApiCertName}'
      }
    }
  }

  resource apimBackend 'backends' = {
    name: '${apimApiShortName}-backend'
    properties: {
      protocol: 'http'
      resourceId: appServiceResourceUri
      credentials: {
        certificateIds: [
          apimCert.id
        ]
      }
      url: appServiceSourceUrl
      tls: {
        validateCertificateName: true
        validateCertificateChain: false
      }
    }
  }

  resource api 'apis' = {
    name: apimApiShortName
    properties: {
      displayName: apimApiDisplayName
      path: apimApiRoutePath
      protocols: [
        'https'
      ]
    }

    resource apiPolicy 'policies' = {
      name: 'policy'
      properties: {
        format: 'rawxml'
        value: format('''
<policies>
  <inbound>
    <set-backend-service backend-id="{0}"/>
    <base />
  </inbound>
</policies>
''', apimBackend.name)
      }
    }
  }
}
