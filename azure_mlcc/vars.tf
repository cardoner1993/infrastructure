variable "naming" {
  description = "The naming module output"
  type = object({
    product_name  = string,
    acr           = string,
    location_name = string,
    tags          = map(string),
  })
}

variable "location" {
  description = "location"
  type        = string
  default     = ""
}

variable "cluster_name" {
  type        = string
  default     = "clustername"
  description = "The name of cluster"
}

variable "vm_priority" {
  type        = string
  default     = "LowPriority"
  description = "The priority of the VM."
}

variable "vm_size" {
  type        = string
  default     = "STANDARD_DS1_V2"
  description = "The size of the VM."
}

variable "machine_learning_workspace_id" {
  type        = string
  description = "The id of the machine learning workspace."
}

variable "subnet_resource_id" {
  type        = string
  default     = ""
  description = "The subnet id of the virtual network."
}

variable "description" {
  type        = string
  default     = ""
  description = "The description of the compute cluster."
}

variable "scale_settings" {
  type = map(string)
  default = {
    min_count      = 0
    max_count      = 1
    scale_duration = "PT120S"
  }
}

variable "ssh" {
  type = map(string)
  default = {
    admin     = ""
    key_value = ""
  }
}

variable "identity_ids" {
  type        = list(string)
  description = "The description of the compute cluster."
  default     = []
}