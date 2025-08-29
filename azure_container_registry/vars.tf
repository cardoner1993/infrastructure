variable "naming" {
  description = "The naming module output"
  type        = object({ resource_group = string, tags = map(string), acr = string, location_name = string })
}

variable "georeplications" {
  description = "georeplications parameters using this format name = [location, redundancy, tags]"
  type        = any
  default     = null
}

variable "resource_group" {
  description = "The name of the resource group in which to create the container registry."
  type        = string
  default     = ""
}

variable "admin_enabled" {
  description = "Enable admin user"
  type        = bool
  default     = false
}

variable "sku" {
  description = "The SKU name of the container registry. Possible values are `Basic`, `Standard`, `Premium`, `Classic`, `Premium_ZRS`, `Standard_ZRS`, `Basic_ZRS`."
  type        = string
  default     = "Standard"
}

variable "network_default_access" {
  description = "The default action when no rule matches. Possible values are `Allow` or `Deny`."
  type        = string
  default     = "Allow"
}

variable "virtual_network_rules" {
  description = "A list of virtual network rules for the container registry."
  type        = list(any)
  default     = []
}

variable "georeplication_locations" {
  description = <<DESC
  A list of Azure locations where the Ccontainer Registry should be geo-replicated. Only activated on Premium SKU.
  Supported properties are:
    location                  = string
    zone_redundancy_enabled   = bool
    regional_endpoint_enabled = bool
    tags                      = map(string)
  or this can be a list of `string` (each element is a location)
DESC
  type        = any
  default     = []
}

variable "ip_rules" {
  description = "A list of IP rules for the container registry."
  type        = list(any)
  default     = []
}

variable "acr_log_analytics_workspace_id" {
  description = "Log Analytics ID for Diagnostic Settings"
  type        = string
  default     = ""
}

variable "env" {
  description = "The environment name"
  type        = string
  default     = "stg"
}

variable "identities" {
  description = "User or Managed identities with [type (SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both)) and identity_ids]"
  type        = any
  default     = null
}
