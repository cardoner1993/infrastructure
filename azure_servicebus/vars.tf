variable "naming" {
  description = "The naming module output"
}

variable "resource_group" {
  type    = string
  default = ""
}

variable "sku" {
  description = "The servicebus namespace Sku. It can be one of Basic, Standard or Premium. Defaults to Standard."
  type        = string
  default     = "Standard"
}

variable "capacity" {
  description = "Specifies the capacity. When sku is Premium, capacity can be 1, 2, 4 or 8. When sku is Basic or Standard, capacity can be 0 only."
  default     = 0
}

variable "geo_recovery" {
  description = "Service Bus Geo-DR Alias."
  type = object({
    alias              = string
    secondary_location = string
  })
  default = {
    alias              = ""
    secondary_location = "North Europe"
  }
}

variable "zone_redundant" {
  description = "Whether or not this resource is zone redundant. sku needs to be Premium. Defaults to false."
  default     = false
}

variable "network_rule_default_action" {
  description = "Specifies the default action for the ServiceBus Namespace Network Rule Set. Possible values are Allow and Deny. Defaults to Deny."
  default     = "Deny"
}

variable "network_ip_rules" {
  description = "One or more IP Addresses, or CIDR Blocks which should be able to access the ServiceBus Namespace."
  default     = null
}

variable "network_subnet_rules" {
  description = "Subnets that will be able to access ServiceBus"
  default     = null
}

variable "queues" {
  description = "Queues."
  default     = null
}

variable "topics" {
  description = "Topics."
  default     = null
}

variable "subscriptions" {
  description = "Subscriptions inside topics."
  default     = null
}

variable "namespace_authorization_rules" {
  description = "Namespace authorization rules"
  default     = null
}

variable "queue_authorization_rules" {
  description = "Queue authorization rules"
  default     = null
}

variable "topic_authorization_rules" {
  description = "Topic authorization rules"
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics ID for the Application Gateway"
  type        = string
  default     = ""
}

variable "minimum_tls_version" {
  description = "(Optional) The minimum supported TLS version for this Service Bus Namespace. Valid values are: 1.0, 1.1 and 1.2. Defaults to 1.2"
  type        = string
  default     = "1.2"
}

variable "infrastructure_encryption" {
  type        = bool
  description = "(Optional) Used to specify whether enable Infrastructure Encryption (Double Encryption). Changing this forces a new resource to be created."
  default     = false
}

variable "premium_messaging_partitions" {
  description = "(Optional) Specifies the number messaging partitions. Only valid when sku is Premium and the minimum number is 1. Possible values include 0, 1, 2, and 4. Defaults to 0 for Standard, Basic namespace. Changing this forces a new resource to be created."
  type        = number
  default     = 0
}