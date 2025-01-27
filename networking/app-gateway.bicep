// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The resource identifier of a dedicated subnet for the app gateway.')
param subnetId string

@description('The resource identifier of a dedicated public ip.')
param publicIpId string

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
// Pre Processing
// -----------------------------------------------------------------------------
// Pre-emptively construct the id, since it is required later in the template, during the creation of resource properties (catch 22!)
var appGatewayName = '${prefix}-agw-${suffix}'
var appGatewayId = '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/applicationGateways/${appGatewayName}'

// -----------------------------------------------------------------------------
// Main Resource
// -----------------------------------------------------------------------------
resource mainResource 'Microsoft.Network/applicationGateways@2023-05-01' = {
  name: appGatewayName
  location: location
  tags: tags
  properties: {
    sku: {
      tier: 'WAF_v2'
      name: 'WAF_v2'
      capacity: 2
    }
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Detection'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIp'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'appGatewayFrontendPort'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appGatewayBackendPool'
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          requestTimeout: 30
        }
      }
    ]
    httpListeners: [
      {
        name: 'appGatewayHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(appGatewayId, 'frontendIPConfigurations/appGatewayFrontendIp')
          }
          frontendPort: {
            id: resourceId(appGatewayId, 'frontendPorts/appGatewayFrontendPort')
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId(appGatewayId, 'httpListeners/appGatewayHttpListener')
          }
          backendAddressPool: {
            id: resourceId(appGatewayId, 'backendAddressPools/appGatewayBackendPool')
          }
          backendHttpSettings: {
            id: resourceId(appGatewayId, 'backendHttpSettingsCollection/appGatewayBackendHttpSettings')
          }
        }
      }
    ]
  }
}

// -----------------------------------------------------------------------------
// Common Output
// -----------------------------------------------------------------------------
@description('The id of the main resource defined in this template.')
output primaryResourceId string = mainResource.id

@description('The name of the main resource defined in this template.')
output resourceName string = mainResource.name
