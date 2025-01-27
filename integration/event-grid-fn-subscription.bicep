// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The resource name of the event grid topic to which to subscribe.')
param topicResourceName string

@description('The function resource identifier.')
param functionResourceId string

// -----------------------------------------------------------------------------
// Common Parameters
// -----------------------------------------------------------------------------
@description('The environment prefix.')
param prefix string

@description('Amalgam of the workload and the (short) location name.')
@minLength(3)
param suffix string

// Get a reference to the parent topic
resource parentTopic 'Microsoft.EventGrid/topics@2023-06-01-preview' existing = {
  name: topicResourceName
}

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.EventGrid/eventSubscriptions@2023-06-01-preview' = {
  name: '${prefix}-evgs-${suffix}'
  scope: parentTopic
  properties: {
    destination: {
      endpointType: 'AzureFunction'
      properties: {
        resourceId: functionResourceId
      }
    }
    eventDeliverySchema: 'EventGridSchema'
  }
}

// -----------------------------------------------------------------------------
// Common Output
// -----------------------------------------------------------------------------
@description('The id of the main resource defined in this template.')
output resourceId string = mainResource.id

@description('The name of the main resource defined in this template.')
output resourceName string = mainResource.name
