// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The name of the app config resource.')
param appConfigResourceName string

@description('The name of the entry.')
param name string

@secure()
@description('The value of the entry.')
param value string

@description('The label of the entry (optional).')
param label string = ''

@description('The content type of the entry (optional).')
param type string = ''

// -----------------------------------------------------------------------------
// Variables
// -----------------------------------------------------------------------------
@description('The label suffix to use.')
var labelSuffix = empty(label) ? '' : '$${label}'

@description('The encoded entry name.')
var encodedName = replace(replace(uriComponent(name), '~', '~7E'), '%', '~')

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  name: '${appConfigResourceName}/${encodedName}${labelSuffix}'
  properties: {
    value: value
    contentType: empty(type) ? null : type
  }
}

// -----------------------------------------------------------------------------
// Common Output
// -----------------------------------------------------------------------------
@description('The id of the main resource defined in this template.')
output resourceId string = mainResource.id

@description('The name of the main resource defined in this template.')
output resourceName string = mainResource.name
