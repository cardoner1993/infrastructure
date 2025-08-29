# azurerm.container_registry

You can use the resource_group module referencing the url `git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.container_registry.git?ref=2.0`. Here you can find an example:

## calling module with azurerm.naming and azurerm.resource_group, azurerm.network_security_group and azurerm.virtual_network. Recommended usage.

```
module "naming" {
  source            = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.naming.git?ref=4.0"
  product_name      = "example"
  product_iteration = "001"              # (optional)
  environment       = "development"
  location          = "West Europe"      # (AZURE)     use location 
  zone_name         = "europe-west3-c"   # (GCP)       or zone_name depends on cloud.
  is_common         = false              # (optional)
  tags = {
    cost-center = "test"
    Chapter     = "DataOps"
    Domain      = "dp"
  }
  custom_names = {
    cn_kv = "custom-name-for-kv",
    cn_rg = "custom-name-for-rg",
  }
}

module "rg" {
  source                 = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.resource_group.git?ref=2.0"
  name                   = module.naming.resource_group
  location               = module.naming.location_name
  tags                   = module.naming.tags
}

module "nsg" {
  source                = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.network_security_group?ref=3.0"
  naming                = module.naming
  resource_group        = module.rg.rg_name
  predefined_rules = [
    {
      name     = "SSH"
      priority = "500"
    },
  ]
}

module "vnet" {
  source              = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.virtual_network?ref=3.0"
  naming              = module.naming
  resource_group      = module.rg.rg_name
  address_space       = ["10.0.0.0/16"]
  subnets = [
    {
      name                      = "subnet-1"
      address_prefixes          = ["10.0.3.0/24"]
      service_endpoints         = ["Microsoft.ContainerRegistry"] 
      network_security_group_id = module.nsg.network_security_group_id

    },
    {
      name                      = "subnet-2"
      address_prefixes          = ["10.0.2.0/24"]
      service_endpoints         = ["Microsoft.ContainerRegistry"] 
      network_security_group_id = module.nsg.network_security_group_id
    },
  ]
}

module "acr" {
  source                   = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.container_registry.git?ref=4.0"
  naming         = module.naming
  resource_group = module.rg.rg_name
  sku            = "Premium"
  admin_enabled  = true
  
  georeplication_locations = [
    {
      location                  = "North Europe"
      zone_redundancy_enabled   = true
      regional_endpoint_enabled = true
      tags = {
        env = var.env
      }
    }
  ] 

  network_default_access = "Deny"
  virtual_network_rules  = [module.vnet.subnets.0]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_monitor_diagnostic_setting.acr-diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr_log_analytics_workspace_id"></a> [acr\_log\_analytics\_workspace\_id](#input\_acr\_log\_analytics\_workspace\_id) | Log Analytics ID for Diagnostic Settings | `string` | `""` | no |
| <a name="input_admin_enabled"></a> [admin\_enabled](#input\_admin\_enabled) | Enable admin user | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | The environment name | `string` | `"stg"` | no |
| <a name="input_georeplication_locations"></a> [georeplication\_locations](#input\_georeplication\_locations) | A list of Azure locations where the Ccontainer Registry should be geo-replicated. Only activated on Premium SKU.<br>  Supported properties are:<br>    location                  = string<br>    zone\_redundancy\_enabled   = bool<br>    regional\_endpoint\_enabled = bool<br>    tags                      = map(string)<br>  or this can be a list of `string` (each element is a location) | `any` | `[]` | no |
| <a name="input_georeplications"></a> [georeplications](#input\_georeplications) | georeplications parameters using this format name = [location, redundancy, tags] | `any` | `null` | no |
| <a name="input_ip_rules"></a> [ip\_rules](#input\_ip\_rules) | A list of IP rules for the container registry. | `list(any)` | `[]` | no |
| <a name="input_naming"></a> [naming](#input\_naming) | The naming module output | `object({ resource_group = string, tags = map(string), acr = string, location_name = string })` | n/a | yes |
| <a name="input_network_default_access"></a> [network\_default\_access](#input\_network\_default\_access) | The default action when no rule matches. Possible values are `Allow` or `Deny`. | `string` | `"Allow"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the resource group in which to create the container registry. | `string` | `""` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU name of the container registry. Possible values are `Basic`, `Standard`, `Premium`, `Classic`, `Premium_ZRS`, `Standard_ZRS`, `Basic_ZRS`. | `string` | `"Standard"` | no |
| <a name="input_virtual_network_rules"></a> [virtual\_network\_rules](#input\_virtual\_network\_rules) | A list of virtual network rules for the container registry. | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acr"></a> [acr](#output\_acr) | The container registry. |
| <a name="output_acr_id"></a> [acr\_id](#output\_acr\_id) | The ID of the container registry. |
| <a name="output_acr_login_server"></a> [acr\_login\_server](#output\_acr\_login\_server) | The login server for the container registry. |
| <a name="output_acr_name"></a> [acr\_name](#output\_acr\_name) | The name of the container registry. |
<!-- END_TF_DOCS -->