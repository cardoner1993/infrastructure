variable "naming" {
  description = "(Required) The naming module output"
  type        = object({ storage_account = string, location_name = string, tags = map(string) })
  nullable    = false
}
variable "resource_group_name" {
  description = "(Required) The resource group"
  type        = string
  nullable    = false
}

variable "kind" {
  type        = string
  default     = "StorageV2"
  description = "The kind of the storage account."
}
variable "sku" {
  type        = string
  default     = "Standard_RAGRS"
  description = "The SKU of the storage account."
}
variable "access_tier" {
  type        = string
  default     = "Hot"
  description = "The access tier of the storage account."
}

variable "https_traffic_only_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Should https only be allowed?"
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  default     = false
  description = "(Optional) Allow or disallow nested items within this Account to opt into being public"
}

variable "is_hns_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Is Hierarchical Namespace enabled?"
}
variable "identity_ids" {
  type        = list(string)
  default     = []
  description = "A list of IDs for User Assigned Managed Identity resources to be assigned."
}
variable "containers" {
  type        = list(string)
  default     = []
  description = "List of containers."
}
variable "queues" {
  type        = list(string)
  default     = []
  description = "List of queues."
}
variable "tables" {
  type        = list(string)
  default     = []
  description = "List of storage tables."
}
variable "shares" {
  type        = any
  default     = null
  description = "A list of files shares you want to create."
}

variable "identity_type" {
  type        = string
  default     = "SystemAssigned"
  description = "The type of identity used for the storage account. Possible values are SystemAssigned and UserAssigned. Changing this forces a new resource to be created."
}


variable "storage_management_lifecycles" {
  description = "Lifecycle rules to apply in datalake"
  type = list(object({
    name         = string
    enabled      = string
    prefix_match = set(string)
    tags_to_apply = list(object({
      name      = string,
      operation = string
      value     = string
    }))
    tier_to_cool_after_days    = string
    tier_to_archive_after_days = string
    delete_after_days          = string
  }))
  default = []
}

########################
# NETWORK RULES CONFIG #
########################

variable "network_bypass" {
  type        = list(string)
  description = "(Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging, Metrics, AzureServices (For example, \"Logging, Metrics\"), or None to bypass none of those traffics."
  default     = ["AzureServices"]
}
variable "allowed_ips" {
  type        = list(string)
  description = "(Optional) List of public IP or IP ranges in CIDR Format. Only IPV4 addresses are allowed. Private IP address ranges (as defined in RFC 1918) are not allowed."
  default     = []
}
variable "allowed_subnets_ids" {
  type        = list(string)
  description = "(Optional) A list of resource ids for subnets."
  default     = []
}

###################
# SECURITY CONFIG #
###################
variable "shared_access_key_enabled" {
  type        = bool
  description = "(Optional) Enable or disable shared access key for the storage account."
  default     = true
}

variable "sftp_enabled" {
  type        = bool
  description = "(Optional) Enable or disable SFTP for the storage account."
  default     = false
}

##########################
# DATA PROTECTION CONFIG #
##########################
variable "storage_blob_data_protection" {
  description = "Storage account blob Data protection parameters."
  type = object({
    change_feed_enabled                       = optional(bool, false)
    versioning_enabled                        = optional(bool, false)
    delete_retention_policy_in_days           = optional(number, 0)
    container_delete_retention_policy_in_days = optional(number, 0)
    container_point_in_time_restore           = optional(bool, false)
  })
  default = {
    change_feed_enabled                       = true
    versioning_enabled                        = true
    delete_retention_policy_in_days           = 30
    container_delete_retention_policy_in_days = 30
    container_point_in_time_restore           = true
  }
}

######################
# CUSTOM DOMAIN NAME #
######################
variable "custom_domain_name" {
  type        = string
  description = "(Optional) The custom domain name."
  default     = null
}
variable "use_subdomain" {
  type        = bool
  description = "(Optional) Use subdomain or not."
  default     = false
}

##################
# STATIC WEBSITE #
##################
variable "enable_static_website" {
  type        = string
  description = "(Optional) Enable static website."
  default     = null
}
