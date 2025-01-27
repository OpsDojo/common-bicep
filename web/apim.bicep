// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The SKU for APIM. Consumption is NOT designed for production workloads that handle user-facing web apis.')
@allowed([
  'Consumption'
  'Developer'
])
param skuName string

@description('The jwt parameters to use on the global inbound policy. Format: { audience, issuer, openIdUrl }.')
param jwtParams object = {}

@description('The resource id of the app insights instance to hook up to apim.')
param appInsightsResourceId string

@description('The instrumentation key of the app insights instance to hook up to apim.')
param appInsightsInstrumentationKey string

@description('The (comma-separated) origins to allow for CORS on APIM.')
param corsOrigins string

@description('CORS origins in APIM policy XML format.')
var corsOriginsPolicyXml = '<origin>${replace(corsOrigins, ',', '</origin><origin>')}</origin>'

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
// Variables
// -----------------------------------------------------------------------------
@description('Xml for JWT policy configuration.')
var jwtPolicyXml = empty(jwtParams) ? '' : format('''
    <validate-jwt header-name="Authorization">
      <openid-config url="{0}" />
      <audiences>
        <audience>{1}</audience>
      </audiences>
      <issuers>
        <issuer>{2}</issuer>
      </issuers>
    </validate-jwt>
''', jwtParams.openIdUrl, jwtParams.audience, jwtParams.issuer)

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: '${prefix}-apim-${suffix}'
  location: location
  tags: tags
  sku: {
    name: skuName
    capacity: skuName == 'Consumption' ? 0 : skuName == 'Developer' ? 1 : 2
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: 'mercurydevelopers@288group.com'
    publisherName: 'Mercury'
  }

  resource apimLogger 'loggers' = {
    name: 'logger'
    properties: {
      resourceId: appInsightsResourceId
      loggerType: 'applicationInsights'
      credentials: {
        instrumentationKey: appInsightsInstrumentationKey
      }
    }
  }

  resource apimDiagnostic 'diagnostics' = {
    name: 'applicationinsights'
    properties: {
      verbosity: 'information'
      loggerId: apimLogger.id
    }
  }

  resource apimBasePolicy 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: format('''
<policies>
  <inbound>
    <cors>
      <allowed-origins>{0}</allowed-origins>
      <allowed-methods>
        <method>*</method>
      </allowed-methods>
      <allowed-headers>
        <header>*</header>
      </allowed-headers>
    </cors>
    {1}
  </inbound>
  <backend>
    <forward-request />
  </backend>
</policies>
''', corsOriginsPolicyXml, jwtPolicyXml)
    }
  }
}

// Obtain a reference to the generated master subscription
resource apimMasterSubscription 'Microsoft.ApiManagement/service/subscriptions@2023-03-01-preview' existing = {
  parent: mainResource
  name: 'master'
}

// -----------------------------------------------------------------------------
// Common Output
// -----------------------------------------------------------------------------
@description('The id of the main resource defined in this template.')
output resourceId string = mainResource.id

@description('The name of the main resource defined in this template.')
output resourceName string = mainResource.name

@description('The service principal (object) id of the main resource defined in this template.')
output resourcePrincipalId string = mainResource.identity.principalId

// -----------------------------------------------------------------------------
// Specific Output
// -----------------------------------------------------------------------------
var publicIps = mainResource.properties.publicIPAddresses

@description('The static public ip address of the apim resource (not provided if on consumption plan).')
output publicIp string = empty(publicIps) ? '' : publicIps[0]

var subKey = apimMasterSubscription.listSecrets().primaryKey
@description('The primary key of the master subscription.')
output subscriptionKey string = subKey
