<!-- BEGIN_TF_DOCS -->

# Azure Kubernetes Terraform Module

## Usages Terraform 1.0
```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "aks-example-resource-group"
  location = "westeurope"
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  vnet_name           = "aks-example-vnet"
  address_space       = "10.0.0.0/8"
  subnet_prefixes     = ["10.0.0.0/16"]
  subnet_names        = ["subnet1"]
  depends_on          = [azurerm_resource_group.example]
}

module "aks" {
  source                    = "../../"
  resource_group_name       = azurerm_resource_group.example.name
  resource_group_location   = azurerm_resource_group.example.location
  kubernetes_version        = "1.22.6"
  orchestrator_version      = "1.22.6"
  prefix                    = "prefix"
  cluster_name              = "example"
  network_plugin            = "azure"
  vnet_subnet_id            = module.network.vnet_subnets[0]
  os_disk_size_gb           = 50
  sku_tier                  = "Free" # defaults to Free
  agents_min_count          = 1
  agents_max_count          = 2
  agents_count              = 1
  agents_max_pods           = 100
  agents_pool_name          = "nodepool"
  agents_availability_zones = ["1"]
  agents_type               = "VirtualMachineScaleSets"

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  network_policy                 = "azure"
  net_profile_dns_service_ip     = "10.1.0.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.1.0.0/16"

  depends_on = [module.network]
}
```

#### Providers

| Name | Version |
|------|---------|
| azurerm | >=3.9.0 |

#### Modules

No modules.

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| kubernetes_version | (Required) Specify which Kubernetes release to use. The default used is the latest Kubernetes version available in the region | `string` |
| orchestrator_version | (Required) Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region | `string` |
| prefix | (Required) The prefix for the resources created in the specified Azure Resource Group | `string` |
| resource_group_location | (Required) The resource group location to be imported | `string` |
| resource_group_name | (Required) The resource group name to be imported | `string` |
| agents_availability_zones | (Optional) A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created. | `list(string)` |
| agents_count | (Optional) The number of Agents that should exist in the Agent Pool. Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes. | `number` |
| agents_labels | (Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. Changing this forces a new resource to be created. | `map(string)` |
| agents_max_count | (Optional) Maximum number of nodes in a pool | `number` |
| agents_max_pods | (Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created. | `number` |
| agents_min_count | (Optional) Minimum number of nodes in a pool | `number` |
| agents_pool_name | (Optional) The default Azure AKS agentpool (nodepool) name. | `string` |
| agents_size | (Optional) The default virtual machine size for the Kubernetes agents. Changing this has no effect on the cluster | `string` |
| agents_tags | (Optional) A mapping of tags to assign to the Node Pool. Changing this has no effect on the cluster | `map(string)` |
| agents_type | (Optional) The type of Node Pool which should be created. Possible values are AvailabilitySet and VirtualMachineScaleSets. Defaults to VirtualMachineScaleSets. | `string` |
| api_server_authorized_ip_ranges | (Optional) The IP ranges to allow for incoming traffic to the server nodes. | `list(string)` |
| azurerm_log_analytics_workspace | (Optional) The full name of the Log Analytics workspace with which the solution will be linked. | `string` |
| blob_driver_enabled | (Optional) Is the Blob CSI driver enabled? Defaults to false | `bool` |
| client_id | (Optional) The Client ID (appId) for the Service Principal used for the AKS deployment | `string` |
| client_secret | (Optional) The Client Secret (password) for the Service Principal used for the AKS deployment | `string` |
| cluster_log_analytics_workspace_name | (Optional) The name of the Analytics workspace | `string` |
| cluster_name | (Optional) The name for the AKS resources created in the specified Azure Resource Group. This variable overwrites the 'prefix' var (The 'prefix' var will still be applied to the dns_prefix if it is set) | `string` |
| critical_addons_enabled | (Optional) Guaranteed Scheduling For Critical Add-On Pods | `bool` |
| disk_driver_enabled | (Optional) Is the Disk CSI driver enabled? Defaults to true. | `bool` |
| disk_driver_version | (Optional) Disk CSI Driver version to be used. Possible values are v1 and v2. Defaults to v1. | `string` |
| enable_auto_scaling | (Optional) Enable node pool autoscaling | `bool` |
| enable_azure_policy | (Optional) Enable azure policy addons | `bool` |
| enable_host_encryption | (Optional)  Enable Host Encryption for default node pool. Encryption at host feature must be enabled on the subscription: https://docs.microsoft.com/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli | `bool` |
| enable_key_vault_secrets_provider | (Optional)  Enable Key Vault CSI provider. | `bool` |
| enable_log_analytics_workspace | (Optional) Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not | `bool` |
| enable_nat_gateway | (Optional) This can only be specified when load_balancer_sku is set to Standard and outbound_type is set to managedNATGateway or userAssignedNATGateway. | `bool` |
| enable_node_public_ip | (Optional) Should nodes in this Node Pool have a Public IP Address? Defaults to false. | `bool` |
| enable_outbund_public_ip | (Optional) This can only be specified when load_balancer_sku is set to Standard and outbound_type is set to managedNATGateway or userAssignedNATGateway. | `bool` |
| enable_role_based_access_control | (Optional) Enable Role Based Access Control. | `bool` |
| file_driver_enabled | (Optional) Is the File CSI driver enabled? Defaults to true. | `bool` |
| http_application_routing_enabled | (Optional) Should HTTP Application Routing be enabled? | `bool` |
| identity_type | (Optional) The type of identity used for the managed cluster. Conflict with `client_id` and `client_secret`. Possible values are `SystemAssigned` and `UserAssigned`. If `UserAssigned` is set, a `user_assigned_identity_id` must be set as well. | `string` |
| local_account_disabled | (Optional) If true local accounts will be disabled. Defaults to false | `bool` |
| log_analytics_workspace_sku | (Optional) The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018 | `string` |
| log_retention_in_days | (Optional) The retention period for the logs in days | `number` |
| nat_gateway_outbound_ip_count | (Optional) Count of desired managed outbound IPs for the cluster load balancer. Must be between 1 and 100 inclusive. | `number` |
| net_profile_dns_service_ip | (Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created. | `string` |
| net_profile_outbound_type | (Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer. | `string` |
| net_profile_pod_cidr | (Optional) The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet. Changing this forces a new resource to be created. | `string` |
| net_profile_service_cidr | (Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created. | `string` |
| network_plugin | (Optional) Network plugin to use for networking. | `string` |
| network_policy | (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created. | `string` |
| nodepools | (Optional) Nodepools to associate to kubernetes. Please set `critical_addons_enabled` `false` while `nodepools` is `{}` to instance containers in system nodepool. | <pre>map(object({<br>    name                = string<br>    availability_zones  = list(string)<br>    enable_auto_scaling = bool<br>    min_count           = number<br>    max_count           = number<br>    node_count          = number<br>    vm_size             = string<br>    os_disk_size_gb     = number<br>    labels              = map(string)<br>    taints              = list(string)<br>  }))</pre> |
| oidc_issuer_enabled | (Optional) If true, the OIDC issuer will be enabled. Defaults to true | `bool` |
| os_disk_size_gb | (Optional) Disk size of nodes in GBs. | `number` |
| private_cluster_enabled | (Optional) If true cluster API server will be exposed only on internal IP address and available only in cluster vnet. | `bool` |
| public_ip_id | public ip id | `string` |
| rbac_aad_admin_group_object_ids | (Optional) Object ID of groups with admin access. | `list(string)` |
| resource_group_name_managed | (Opcional) The resource group name for managed resources to be imported | `string` |
| sku_tier | (Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid | `string` |
| snapshot_controller_enabled | (Optional) Is the Snapshot Controller enabled? Defaults to true. | `bool` |
| tags | (Optional) Any tags that should be present on the Virtual Network resources | `map(string)` |
| user_assigned_identity_client_id | (Optional) The Client ID of a user assigned identity. | `string` |
| user_assigned_identity_id | (Optional) The ID of a user assigned identity. | `string` |
| user_assigned_identity_object_id | (Optional) The objetct ID of a user assigned identity. | `string` |
| vnet_subnet_id | (Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created. | `string` |
| workload_identity_enabled | (Optional) Specifies whether Azure AD Workload Identity should be enabled for the Cluster. Defaults to false. | `bool` |
| maintenance_node_os | (Optional) Define the maintenance configuration for node os | <pre>object({<br>  enabled      = bool<br>  frequency    = string<br>  interval     = number<br>  duration     = number<br>  day_of_month = number<br>  start_time   = string<br>  utc_offset   = string<br>})</pre>

#### Outputs

| Name | Description |
|------|-------------|
| aks_id | Azure Kubernetes resource identifier. |
| kube_config | Azure Kubernetes kube config. |
| kube_config_raw | Azure Kubernetes kube config file. |
| kubelet_identity | A kubelet_identity block as defined below. |
| location | Kubernetes default location resource group. |
| node_resource_group | n/a |
| oidc_issuer_url | n/a |


<!-- END_TF_DOCS -->