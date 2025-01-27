// -----------------------------------------------------------------------------
// Specific Parameters
// -----------------------------------------------------------------------------
@description('The kubernetes version. If no value is specified (recommended), the current default is used.')
param k8sVersion string

@minValue(0)
@maxValue(1000)
@description('The number of "nodes" (aka agents / VMs) to host the containers.')
param totalNodes int

@minLength(8)
@description('The name of the nodes dedicated resource group')
param nodesResourceGroup string

@minValue(0)
@maxValue(1023)
@description('The OS Disk Size in GB to be used to specify the disk size for every machine in the master/agent pool. To use default size, set the value to 0.')
param osDiskSizeGb int

@minLength(7)
@description('The virtual network subnet id for nodes (and pods).')
param nodeSubnetId string

@description('The admin login username for node VMs. If no value is specified such a user is not created.')
param nodeAdminUsername string

@secure()
@description('The admin login public SSH key. The "nodeAdminUsername" value must also be set if using this.')
param nodeAdminPublicSshKey string

@description('Whether to enable private cluster. More secure by default, but requires private links to any Azure resources such as databases, container registries, key vaults, etc etc. This setting cannot be changed after the initial deployment.')
param enablePrivateCluster bool

@description('Whether to encrypt nodes at host. (Only supported for select VMs and regions).')
param encryptNodesAtHost bool

@description('The log analytics workspace resource id.')
param logAnalyticsId string

@description('The application gateway resource id to use as ingress control. Use an empty string to skip AGIC.')
param appGatewayId string

@description('The SKU tier name.')
@allowed([
  'Free'
  'Paid'
])
param skuTierName string

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
resource mainResource 'Microsoft.ContainerService/managedClusters@2023-08-02-preview' = {
  name: '${prefix}-aks-${suffix}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned' // Let Azure manage the identity (highly recommended)
  }
  sku: {
    name: 'Basic'
    tier: skuTierName
  }
  properties: {
    kubernetesVersion: k8sVersion
    addonProfiles: {
      azurePolicy: {
        enabled: true
      }
      ingressApplicationGateway: empty(appGatewayId) ? {} : {
        enabled: true
        config: {
          applicationGatewayId: appGatewayId
        }
      }
      omsAgent: empty(logAnalyticsId) ? {} : {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsId
        }
      }
    }
    agentPoolProfiles: [
      {
        orchestratorVersion: k8sVersion
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGb
        osDiskType: 'Ephemeral'
        count: totalNodes
        enableAutoScaling: true
        minCount: 1
        maxCount: 20
        maxPods: 30
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        availabilityZones: split('1,2,3', ',')
        enableEncryptionAtHost: encryptNodesAtHost
        vnetSubnetID: nodeSubnetId
      }
    ]
    apiServerAccessProfile: {
      enablePrivateCluster: enablePrivateCluster
    }
    dnsPrefix: '${prefix}-dns-${suffix}'
    enableRBAC: true
    linuxProfile: empty(nodeAdminUsername) ? null : {
      adminUsername: nodeAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: nodeAdminPublicSshKey
          }
        ]
      }
    }
    nodeResourceGroup: nodesResourceGroup
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      loadBalancerSku: 'standard'
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
      //dockerBridgeCidr: '172.17.0.1/16'
      outboundType: 'loadBalancer'
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

@description('The service principal (object) id of the main resource defined in this template.')
output resourcePrincipalId string = mainResource.identity.principalId

// -----------------------------------------------------------------------------
// Specific Output
// -----------------------------------------------------------------------------
@description('The fully-qualified domain name of the control plane.')
output controlPlaneFqdn string = mainResource.properties.fqdn

@description('The object id of the kubelet identity.')
output kubeletId string = mainResource.properties.identityProfile.kubeletidentity.objectId
