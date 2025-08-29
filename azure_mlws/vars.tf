variable "naming" {
  description = "The naming module output. Define in the object the allowed elements."
  type = object({
    storage_account    = string,
    tags               = map(string),
    location_name      = string,
    resource_group     = string,
    key_vault          = string,
    app_insights       = string,
    ml_workspace       = string,
    environment        = string,
    adap_dp_subnet_id  = string,
    dp_subscription_id = string
  })
}

variable "resource_group" {
  description = "The resource group"
  type        = string
  default     = ""
}

variable "network_rules" {
  description = "A list of resource ips and subnets allowed"
  type        = map(any)
  default = {
    allowed_subnets_ids = ""
    allowed_ips         = ""
  }
}

variable "diagnositc_setings" {
  description = "Add a workspace_id to the application insights"
  type        = bool
  default     = true
}

variable "ssh" {
  description = "(Optional) Credentials for an administrator user account that will be created on each compute node"
  type        = map(string)
  default = {
    admin     = ""
    key_value = ""
  }
}

variable "azuerml_datastore" {
  description = "List of Azure ML datastores to create. If empty datastore won't be created."
  type        = list(string)
  default     = []
}