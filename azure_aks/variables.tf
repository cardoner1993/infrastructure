variable "agents_availability_zones" {
  description = "(Optional) A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created."
  type        = list(string)
  default     = null
}

variable "agents_count" {
  description = "(Optional) The number of Agents that should exist in the Agent Pool. Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes."
  type        = number
  default     = 2
}

variable "agents_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. Changing this forces a new resource to be created."
  type        = map(string)
  default     = {}
}
variable "agents_max_count" {
  type        = number
  description = "(Optional) Maximum number of nodes in a pool"
  default     = 1000
}

variable "agents_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 100
}

variable "agents_min_count" {
  type        = number
  description = "(Optional) Minimum number of nodes in a pool"
  default     = 1
}

variable "agents_pool_name" {
  description = "(Optional) The default Azure AKS agentpool (nodepool) name."
  type        = string
  default     = "default"
}

variable "agents_size" {
  description = "(Optional) The default virtual machine size for the Kubernetes agents. Changing this has no effect on the cluster"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "agents_tags" {
  description = "(Optional) A mapping of tags to assign to the Node Pool. Changing this has no effect on the cluster"
  type        = map(string)
  default     = {}
}

variable "agents_type" {
  description = "(Optional) The type of Node Pool which should be created. Possible values are AvailabilitySet and VirtualMachineScaleSets. Defaults to VirtualMachineScaleSets."
  type        = string
  default     = "VirtualMachineScaleSets"
}

variable "api_server_authorized_ip_ranges" {
  description = "(Optional) The IP ranges to allow for incoming traffic to the server nodes."
  type        = list(string)
  default     = []
}
variable "azurerm_log_analytics_workspace" {
  description = "(Optional) The full name of the Log Analytics workspace with which the solution will be linked."
  type        = string
  default     = null
}

variable "client_id" {
  description = "(Optional) The Client ID (appId) for the Service Principal used for the AKS deployment"
  type        = string
  default     = ""
}

variable "client_secret" {
  description = "(Optional) The Client Secret (password) for the Service Principal used for the AKS deployment"
  type        = string
  default     = ""
}

variable "cluster_log_analytics_workspace_name" {
  description = "(Optional) The name of the Analytics workspace"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "(Optional) The name for the AKS resources created in the specified Azure Resource Group. This variable overwrites the 'prefix' var (The 'prefix' var will still be applied to the dns_prefix if it is set)"
  type        = string
  default     = null
}

variable "critical_addons_enabled" {
  description = "(Optional) Guaranteed Scheduling For Critical Add-On Pods"
  type        = bool
  default     = false
}

variable "enable_auto_scaling" {
  description = "(Optional) Enable node pool autoscaling"
  type        = bool
  default     = false
}

variable "enable_azure_policy" {
  description = "(Optional) Enable azure policy addons"
  type        = bool
  default     = false
}

variable "enable_host_encryption" {
  description = "(Optional)  Enable Host Encryption for default node pool. Encryption at host feature must be enabled on the subscription: https://docs.microsoft.com/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli"
  type        = bool
  default     = false
}

variable "enable_key_vault_secrets_provider" {
  description = "(Optional)  Enable Key Vault CSI provider."
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "(Optional) This can only be specified when load_balancer_sku is set to Standard and outbound_type is set to managedNATGateway or userAssignedNATGateway."
  type        = bool
  default     = false
}

variable "enable_role_based_access_control" {
  description = "(Optional) Enable Role Based Access Control."
  type        = bool
  default     = false
}

variable "enable_log_analytics_workspace" {
  type        = bool
  description = "(Optional) Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  default     = false
}

variable "identity_type" {
  description = "(Optional) The type of identity used for the managed cluster. Conflict with `client_id` and `client_secret`. Possible values are `SystemAssigned` and `UserAssigned`. If `UserAssigned` is set, a `user_assigned_identity_id` must be set as well."
  type        = string
  default     = "SystemAssigned"
}

variable "kubernetes_version" {
  description = "(Required) Specify which Kubernetes release to use. The default used is the latest Kubernetes version available in the region"
  type        = string
}

variable "local_account_disabled" {
  description = "(Optional) If true local accounts will be disabled. Defaults to false"
  type        = bool
  default     = false
}

variable "oidc_issuer_enabled" {
  description = "(Optional) If true, the OIDC issuer will be enabled. Defaults to true"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_sku" {
  description = "(Optional) The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "(Optional) The retention period for the logs in days"
  type        = number
  default     = 30
}

variable "nat_gateway_outbound_ip_count" {
  description = "(Optional) Count of desired managed outbound IPs for the cluster load balancer. Must be between 1 and 100 inclusive."
  type        = number
  default     = 1
}

variable "net_profile_dns_service_ip" {
  description = "(Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "net_profile_outbound_type" {
  description = "(Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer."
  type        = string
  default     = "loadBalancer"
}

variable "net_profile_pod_cidr" {
  description = " (Optional) The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "net_profile_service_cidr" {
  description = "(Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "network_plugin" {
  description = "(Optional) Network plugin to use for networking."
  type        = string
  default     = "kubenet"
}

variable "network_policy" {
  description = "(Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "nodepools" {
  description = "(Optional) Nodepools to associate to kubernetes. Please set `critical_addons_enabled` `false` while `nodepools` is `{}` to instance containers in system nodepool."
  type = map(object({
    name                = string
    availability_zones  = list(string)
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    node_count          = number
    vm_size             = string
    os_disk_size_gb     = number
    labels              = map(string)
    taints              = list(string)
  }))
  default = {}
}
variable "linux_os_config" {
  description = "Configuraciones del sistema operativo Linux"
  nullable    = true
  type = object({
    transparent_huge_page_defrag  = string
    transparent_huge_page_enabled = string
    sysctl_config = object({
      fs_file_max           = number
      net_ipv4_tcp_tw_reuse = bool
      vm_max_map_count      = number
  }) })
  default = {
    transparent_huge_page_defrag  = "defer+madvise"
    transparent_huge_page_enabled = "madvise"
    sysctl_config = {
      fs_aio_max_nr               = null
      fs_file_max                 = null
      net_ipv4_tcp_tw_reuse       = false
      vm_max_map_count            = null
      fs_inotify_max_user_watches = null
    }
  }
}

variable "orchestrator_version" {
  description = "(Required) Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region"
  type        = string
}

variable "os_disk_size_gb" {
  description = "(Optional) Disk size of nodes in GBs."
  type        = number
  default     = 50
}

variable "prefix" {
  description = "(Required) The prefix for the resources created in the specified Azure Resource Group"
  type        = string
}

variable "private_cluster_enabled" {
  description = "(Optional) If true cluster API server will be exposed only on internal IP address and available only in cluster vnet."
  type        = bool
  default     = false
}

variable "rbac_aad_admin_group_object_ids" {
  description = "(Optional) Object ID of groups with admin access."
  type        = list(string)
  default     = null
}

variable "resource_group_name" {
  description = "(Required) The resource group name to be imported"
  type        = string
}

variable "resource_group_location" {
  description = "(Required) The resource group location to be imported"
  type        = string
}

variable "resource_group_name_managed" {
  description = "(Opcional) The resource group name for managed resources to be imported"
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid"
  type        = string
  default     = "Free"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Any tags that should be present on the Virtual Network resources"
  default     = {}
}

variable "user_assigned_identity_client_id" {
  description = "(Optional) The Client ID of a user assigned identity."
  type        = string
  default     = null
}

variable "user_assigned_identity_id" {
  description = "(Optional) The ID of a user assigned identity."
  type        = string
  default     = null
}

variable "user_assigned_identity_object_id" {
  description = "(Optional) The objetct ID of a user assigned identity."
  type        = string
  default     = null
}

variable "vnet_subnet_id" {
  description = "(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "public_ip_id" {
  description = "public ip id"
  type        = string
  default     = null
}
variable "enable_outbund_public_ip" {
  description = "(Optional) This can only be specified when load_balancer_sku is set to Standard and outbound_type is set to managedNATGateway or userAssignedNATGateway."
  type        = bool
  default     = false
}
variable "enable_node_public_ip" {
  description = "(Optional) Should nodes in this Node Pool have a Public IP Address? Defaults to false."
  type        = bool
  default     = false
}

variable "workload_identity_enabled" {
  description = "(Optional) Specifies whether Azure AD Workload Identity should be enabled for the Cluster. Defaults to false."
  type        = bool
  default     = false
}

variable "http_application_routing_enabled" {
  description = "(Optional) Should HTTP Application Routing be enabled?"
  type        = bool
  default     = false
}

variable "blob_driver_enabled" {
  description = "(Optional) Is the Blob CSI driver enabled? Defaults to false"
  type        = bool
  default     = false
}

variable "disk_driver_enabled" {
  description = "(Optional) Is the Disk CSI driver enabled? Defaults to true."
  type        = bool
  default     = true
}

variable "disk_driver_version" {
  description = "(Optional) Disk CSI Driver version to be used. Possible values are v1 and v2. Defaults to v1."
  type        = string
  default     = "v1"
}

variable "file_driver_enabled" {
  description = "(Optional) Is the File CSI driver enabled? Defaults to true."
  type        = bool
  default     = true
}

variable "snapshot_controller_enabled" {
  description = "(Optional) Is the Snapshot Controller enabled? Defaults to true."
  type        = bool
  default     = true
}

variable "drain_timeout_in_minutes" {
  description = "(Optional) The amount of time in minutes to wait on eviction of pods and graceful termination per node. This eviction wait time honors pod disruption budgets for upgrades. If this time is exceeded, the upgrade fails. Unsetting this after configuring it will force a new resource to be created."
  type        = number
  default     = 0
}
variable "node_soak_duration_in_minutes" {
  description = "(Optional) The amount of time in minutes to wait after draining a node and before reimaging and moving on to next node. Defaults to 0."
  type        = number
  default     = 0
}
variable "max_surge" {
  description = "(Required) The maximum number or percentage of nodes which will be added to the Node Pool size during an upgrade."
  type        = string
  default     = "10%"
}
variable "maintenance_node_os" {
  description = "(Optional) Define the maintenance configuration for node os"
  type        = map(string)
  default = {
    "enabled"     = false
    "frequency"   = "Weekly" # (Required) Frequency of maintenance. Possible options are Daily, Weekly, AbsoluteMonthly and RelativeMonthly.
    "interval"    = "1"      # (Required) The interval for maintenance runs. Depending on the frequency this interval is week or month based.
    "duration"    = "4"      # (Required) The duration of the window for maintenance to run in hours. Possible options are between 4 to 24.
    "day_of_week" = "Monday" # (Optional) The day of the week for the maintenance run. Required in combination with weekly frequency. Possible values are Friday, Monday, Saturday, Sunday, Thursday, Tuesday and Wednesday.
    "start_time"  = "12:00"  # (Optional) The time for maintenance to begin, based on the timezone determined by utc_offset. Format is HH:mm.
    "utc_offset"  = "+00:00" # (Optional) Used to determine the timezone for cluster maintenance.
  }
}