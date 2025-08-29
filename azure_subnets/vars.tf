variable "naming" {
  description = "The naming module output"
  type = object({
    nsg            = string,
    subnet         = string,
    location_name  = string,
    resource_group = string,
    product_name   = string,
  })
}

variable "resource_group_name" {
  description = "The resource group"
  type        = string
  default     = ""
}

variable "vnet_name" {
  description = "virtual network name"
  type        = string
}

variable "subnets" {
  description = "Subnets object"
}
