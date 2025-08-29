<!-- BEGIN_TF_DOCS -->
# Azure Storage Account Module

This module deploys an Azure Storage Account.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.47.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_advanced_threat_protection.threat_protection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/advanced_threat_protection) | resource |
| [azurerm_storage_account.stg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.containers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.lcpolicy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |
| [azurerm_storage_queue.queues](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_storage_share.shares](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_table.tables](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) | resource |

## Example of the Module

```hcl
terraform {
  required_version = ">=1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "naming" {
  source            = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.naming?ref=5.2"
  product_name      = "s00-wspace"
  product_iteration = "001"
  environment       = "dev"
  location          = "west europe"
  tags = {
    <ADD TAGS HERE>
  }
}

module "rg" {
  source = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.resource_group?ref=5.0"
  naming = module.naming
}

module "vnet" {
  source                     = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.virtual_network?ref=5.0"
  naming                     = module.naming
  resource_group_name        = module.rg.name
  address_space              = ["192.168.1.0/24", "192.168.2.0/24"]
  dns_servers                = ["1.1.1.1"]
  log_analytics_workspace_id = module.naming.dp_azlog
}

module "snets" {
  source              = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.subnets?ref=5.0"
  naming              = module.naming
  resource_group_name = module.rg.name
  vnet_name           = module.vnet.name
  subnets             = [{ name = "subnet-storage-account", prefixes = ["192.168.1.128/26"], service_endpoints = ["Microsoft.Storage"] }]
}


module "stg" {
  source              = "../../"
  naming              = module.naming
  resource_group_name = module.rg.name
  containers          = ["container-1", "container-2"]
  queues              = ["queues-1", "queues-2"]
  tables              = ["tables1", "tables2"]
  shares              = [{ name = "share-1", quota = 50 }, { name = "share-2", quota = 50 }]
  allowed_ips         = module.naming.ips
  allowed_subnets_ids = [module.snets.resource["subnet-storage-account"].id]
  storage_blob_data_protection = {
    change_feed_enabled                       = true
    versioning_enabled                        = true
    delete_retention_policy_in_days           = 42
    container_delete_retention_policy_in_days = 42
    container_point_in_time_restore           = true
  }
  enable_static_website           = "enabled"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = true
}

output "all_module_outputs" {
  value     = module.stg
  sensitive = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | The access tier of the storage account. | `string` | `"Hot"` | no |
| <a name="input_allow_nested_items_to_be_public"></a> [allow\_nested\_items\_to\_be\_public](#input\_allow\_nested\_items\_to\_be\_public) | (Optional) Allow nested items to be publicly accessible when | `bool` | `true` | no |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | (Optional) List of public IP or IP ranges in CIDR Format. Only IPV4 addresses are allowed. Private IP address ranges (as defined in RFC 1918) are not allowed. | `list(string)` | `[]` | no |
| <a name="input_allowed_subnets_ids"></a> [allowed\_subnets\_ids](#input\_allowed\_subnets\_ids) | (Optional) A list of resource ids for subnets. | `list(string)` | `[]` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | List of containers. | `list(string)` | `[]` | no |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | (Optional) The custom domain name. | `string` | `null` | no |
| <a name="input_enable_https_traffic_only"></a> [enable\_https\_traffic\_only](#input\_enable\_https\_traffic\_only) | (Optional) Should https only be allowed? | `bool` | `true` | no |
| <a name="input_enable_static_website"></a> [enable\_static\_website](#input\_enable\_static\_website) | (Optional) Enable static website. | `string` | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | A list of IDs for User Assigned Managed Identity resources to be assigned. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The type of identity used for the storage account. Possible values are SystemAssigned and UserAssigned. Changing this forces a new resource to be created. | `string` | `"SystemAssigned"` | no |
| <a name="input_is_hns_enabled"></a> [is\_hns\_enabled](#input\_is\_hns\_enabled) | (Optional) Is Hierarchical Namespace enabled? | `bool` | `false` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | The kind of the storage account. | `string` | `"StorageV2"` | no |
| <a name="input_naming"></a> [naming](#input\_naming) | (Required) The naming module output | `object({ storage_account = string, location_name = string, tags = map(string) })` | n/a | yes |
| <a name="input_network_bypass"></a> [network\_bypass](#input\_network\_bypass) | (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging, Metrics, AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics. | `list(string)` | <pre>[<br>  "AzureServices"<br>]</pre> | no |
| <a name="input_queues"></a> [queues](#input\_queues) | List of queues. | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The resource group | `string` | n/a | yes |
| <a name="input_sftp_enabled"></a> [sftp\_enabled](#input\_sftp\_enabled) | (Optional) Enable or disable SFTP for the storage account. | `bool` | `false` | no |
| <a name="input_shared_access_key_enabled"></a> [shared\_access\_key\_enabled](#input\_shared\_access\_key\_enabled) | (Optional) Enable or disable shared access key for the storage account. | `bool` | `true` | no |
| <a name="input_shares"></a> [shares](#input\_shares) | A list of files shares you want to create. | `any` | `null` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the storage account. | `string` | `"Standard_RAGRS"` | no |
| <a name="input_storage_blob_data_protection"></a> [storage\_blob\_data\_protection](#input\_storage\_blob\_data\_protection) | Storage account blob Data protection parameters. | <pre>object({<br>    change_feed_enabled                       = optional(bool, false)<br>    versioning_enabled                        = optional(bool, false)<br>    delete_retention_policy_in_days           = optional(number, 0)<br>    container_delete_retention_policy_in_days = optional(number, 0)<br>    container_point_in_time_restore           = optional(bool, false)<br>  })</pre> | <pre>{<br>  "change_feed_enabled": true,<br>  "container_delete_retention_policy_in_days": 30,<br>  "container_point_in_time_restore": true,<br>  "delete_retention_policy_in_days": 30,<br>  "versioning_enabled": true<br>}</pre> | no |
| <a name="input_storage_management_lifecycles"></a> [storage\_management\_lifecycles](#input\_storage\_management\_lifecycles) | Lifecycle rules to apply in datalake | <pre>list(object({<br>    name         = string<br>    enabled      = string<br>    prefix_match = set(string)<br>    tags_to_apply = list(object({<br>      name      = string,<br>      operation = string<br>      value     = string<br>    }))<br>    tier_to_cool_after_days    = string<br>    tier_to_archive_after_days = string<br>    delete_after_days          = string<br>  }))</pre> | `[]` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | List of storage tables. | `list(string)` | `[]` | no |
| <a name="input_use_subdomain"></a> [use\_subdomain](#input\_use\_subdomain) | (Optional) Use subdomain or not. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key"></a> [access\_key](#output\_access\_key) | The storage account access key |
| <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string) | The storage account connection string |
| <a name="output_id"></a> [id](#output\_id) | The storage account ID |
| <a name="output_name"></a> [name](#output\_name) | The storage account name |
| <a name="output_resource"></a> [resource](#output\_resource) | The storage account resource |
<!-- END_TF_DOCS -->