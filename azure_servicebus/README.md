# azurerm.servicebus
You can use the servicebus module referencing the url `git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.servicebus?ref=5.2`.

#### Requirements
| Name | Version |
|------|---------|
| Terraform | >= 1.1.0 |
| Azurerm | >= 2.28.0 |
| Module naming | >= 5.1 |
| Module rg | >= 5.0 |

#### Inputs
| Name | Required | Type | Default | Description |
|------|----------|------|---------|-------------|
| naming | Required | `object` | none | A reference to the naming module. Take care of it, as Key Vault only allows maximum 24 characters name.
| resource_group | Optional | `object` | none | Resource group name. In case you don't specify a name the module will create a RG automatically using the naming module.
| sku | Optional | `string` | Standard | The Name of the SKU used for this Key Vault. Possible values are `Basic`, `Standard` and `Premium`. Defaults to `Standard`.
| capacity | Optional | `number` | none | Specifies the capacity. When sku is Premium, capacity can be `1`, `2`, `4` or `8`. When sku is `Basic` or `Standard`, capacity can be `0` only. Defaults to `0`.
| zone_redundant | Optional | `bool` | false | Whether or not this resource is zone redundant. sku needs to be `Premium`. Defaults to `false`.
| network_rule_default_action | Optional | `string` | Deny | Specifies the default action for the ServiceBus Namespace Network Rule Set. Possible values are `Allow` and `Deny`. Defaults to `Deny`.
| network_ip_rules | Optional | `list`| none | of one or more IP Addresses, or CIDR Blocks which should be able to access the ServiceBus Namespace.
| network_subnet_rules | Optional | `map(string)` | none | Subnets that will be allowed to access the ServiceBus namespace. Includes: **subnet_id**: (Optional) Subnet ID.**ignore_missing_vnet_service_endpoint**: (Optional) Should the ServiceBus Namespace Network Rule Set ignore missing Virtual Network Service Endpoint option in the Subnet? Defaults to `false`.
| namespace_authorization_rules | Optional | `map(string)` | none | Manages a ServiceBus Namespace authorization Rule within a ServiceBus. Includes: **name**: (Required) Specifies the name of the ServiceBus Namespace Authorization Rule resource. Changing this forces a new resource to be created. **listen**: (Optional) Grants listen access to this this Authorization Rule. Defaults to `true`. **send**: (Optional) Grants send access to this this Authorization Rule. Defaults to `true`. **manage**: (Optional) Grants manage access to this this Authorization Rule. When this property is `true` - both listen and send must be too. Defaults to `false`.
| queues | Optional | `list(map(string))` | none | A list of up to 16 objects describing access policies. Includes: **name**: (Required) Specifies the name of the ServiceBus Queue resource. Changing this forces a new resource to be created. **lock_duration**: (Optional) The ISO 8601 timespan duration of a peek-lock; that is, the amount of time that the message is locked for other receivers. Maximum value is 5 minutes. Defaults to 1 minute (`PT1M`).**max_size_in_megabytes**: (Optional) Integer value which controls the size of memory allocated for the queue. For supported values see the "Queue or topic size" section of Service Bus Quotas. Defaults to `1024`. **requires_duplicate_detection**: (Optional) Boolean flag which controls whether the Queue requires duplicate detection. Changing this forces a new resource to be created. Defaults to `false`. **requires_session**: (Optional) Boolean flag which controls whether the Queue requires sessions. This will allow ordered handling of unbounded sequences of related messages. With sessions enabled a queue can guarantee first-in-first-out delivery of messages. Changing this forces a new resource to be created. Defaults to `false`. **default_message_ttl**: (Optional) The ISO 8601 timespan duration of the TTL of messages sent to this queue. This is the default value used when TTL is not set on message itself. **dead_lettering_on_message_expiration**: (Optional) Boolean flag which controls whether the Queue has dead letter support when a message expires. Defaults to `false`. **duplicate_detection_history_time_window**: (Optional) The ISO 8601 timespan duration during which duplicates can be detected. Defaults to 10 minutes (`PT10M`).**max_delivery_count**: (Optional) Integer value which controls when a message is automatically dead lettered. Defaults to `10`. **status**: (Optional) The status of the Queue. Possible values are `Active`, `Creating`, `Deleting`, `Disabled`, `ReceiveDisabled`, `Renaming`, `SendDisabled`, `Unknown`. Note that Restoring is not accepted. Defaults to `Active`. **enable_batched_operations**: (Optional) Boolean flag which controls whether server-side batched operations are enabled. Defaults to `true`. **auto_delete_on_idle**: (Optional) The ISO 8601 timespan duration of the idle interval after which the Queue is automatically deleted, minimum of 5 minutes. **enable_partitioning**: (Optional) Boolean flag which controls whether to enable the queue to be partitioned across multiple message brokers. Changing this forces a new resource to be created. Defaults to `false` for `Basic` and `Standard`. For `Premium`, it MUST be set to `true`. **enable_express**: (Optional) Boolean flag which controls whether Express Entities are enabled. An express queue holds a message in memory temporarily before writing it to persistent storage. Defaults to `false` for `Basic` and `Standard`. For `Premium`, it MUST be set to `false`. **forward_to**: (Optional) The name of a Queue or Topic to automatically forward messages to.**forward_dead_lettered_messages_to**: (Optional) The name of a Queue or Topic to automatically forward dead lettered messages to.
| queue_authorization_rules | Optional | `map` | none | You can only specify one block: Includes: **name**: (Required) Specifies the name of the Authorization Rule. Changing this forces a new resource to be created. **queue_name**: (Required) Specifies the name of the ServiceBus Queue. Changing this forces a new resource to be created. **listen**: (Optional) Grants listen access to this this Authorization Rule. Defaults to `true`. **send**: (Optional) Grants send access to this this Authorization Rule. Defaults to `true`.**manage**: (Optional) Grants manage access to this this Authorization Rule. When this property is `true` - both listen and send must be too. Defaults to `false`.
| topics | Optional | `list(map(string))` | none | A list of up to 16 objects describing access policies. Includes: **name**: (Required) Specifies the name of the ServiceBus Topic resource. Changing this forces a new resource to be created. **status**: (Optional) The Status of the Service Bus Topic. Acceptable values are `Active` or `Disabled`. Defaults to `Active`. **auto_delete_on_idle**: (Optional) The ISO 8601 timespan duration of the idle interval after which the Topic is automatically deleted, minimum of 5 minutes.**default_message_ttl**: (Optional) The ISO 8601 timespan duration of TTL of messages sent to this topic if no TTL value is set on the message itself.**duplicate_detection_history_time_window**: (Optional) The ISO 8601 timespan duration during which duplicates can be detected. Defaults to 10 minutes. (`PT10M`)**enable_batched_operations**: (Optional) Boolean flag which controls if server-side batched operations are enabled. Defaults to `false`. **enable_express**: (Optional) Boolean flag which controls whether Express Entities are enabled. An express topic holds a message in memory temporarily before writing it to persistent storage. Defaults to `false`.**enable_partitioning**: (Optional) Boolean flag which controls whether to enable the topic to be partitioned across multiple message brokers. Defaults to `false`. Changing this forces a new resource to be created. **max_size_in_megabytes**: (Optional) Integer value which controls the size of memory allocated for the topic.  **requires_duplicate_detection**: (Optional) Boolean flag which controls whether the Topic requires duplicate detection. Defaults to `false`. Changing this forces a new resource to be created. **support_ordering**: (Optional) Boolean flag which controls whether the Topic supports ordering. Defaults to `false`.
| topic_authorization_rules | Optional | `map` | none | You can only specify one block. Includes: **name**: (Required) Specifies the name of the ServiceBus Topic Authorization Rule resource. Changing this forces a new resource to be created. **topic_name**: (Required) Specifies the name of the ServiceBus Topic. Changing this forces a new resource to be created. **listen**: (Optional) Grants listen access to this this Authorization Rule. Defaults to `true`. **send**: (Optional) Grants send access to this this Authorization Rule. Defaults to `true`. **manage**: (Optional) Grants manage access to this this Authorization Rule. When this property is `true` - both listen and send must be too. Defaults to `false`.
| subscriptions | Optional | `list(map(string))` | none | A list of up to 16 objects describing access policies. Includes: **name**: (Required) Specifies the name of the ServiceBus Subscription resource. Changing this forces a new resource to be created.**topic_name**: (Required) The name of the ServiceBus Topic to create this Subscription in. Changing this forces a new resource to be created. **max_delivery_count**: (Optional) The maximum number of deliveries. **auto_delete_on_idle**: (Optional) The idle interval after which the topic is automatically deleted as an ISO 8601 duration. The minimum duration is `5` minutes or `P5M`. **default_message_ttl**: (Optional) The Default message timespan to live as an ISO 8601 duration. This is the duration after which the message expires, starting from when the message is sent to Service Bus. This is the default value used when TimeToLive is not set on a message itself. **lock_duration**: (Optional) The lock duration for the subscription as an ISO 8601 duration. The default value is `1` minute or `P1M`.**dead_lettering_on_message_expiration**: (Optional) Boolean flag which controls whether the Subscription has dead letter support when a message expires. Defaults to `false`.**dead_lettering_on_filter_evaluation_error**: (Optional) Boolean flag which controls whether the Subscription has dead letter support on filter evaluation exceptions. Defaults to `true`. **enable_batched_operations**: (Optional) Boolean flag which controls whether the Subscription supports batched operations. Defaults to `false`. **requires_session**: (Optional) Boolean flag which controls whether this Subscription supports the concept of a session. Defaults to `false`. Changing this forces a new resource to be created.**forward_to**: (Optional) The name of a Queue or Topic to automatically forward messages to.**forward_dead_lettered_messages_to**: (Optional) The name of a Queue or Topic to automatically forward Dead Letter messages to. **status**: (Optional) The status of the Subscription. Possible values are `Active`,`ReceiveDisabled`, or `Disabled`. Defaults to `Active`. **sql_filter**: (Optional) Represents a filter written in SQL language-based syntax that to be evaluated against a BrokeredMessage. Defaults to `1=1`.**sql_filter_action**: (Optional) Represents set of actions written in SQL language-based syntax that is performed against a BrokeredMessage.
| log_analytics_workspace_id | Optional | `string` | "" | Log analytics workspace for diagnostic settings.
| geo_recovery | Optional | map | { alias = "name of failover", secondary_location = "North Europe" } | Service Bus Geo-DR Alias, if alias name exit, will be created failover.
| minimum_tls_version | Optional | `string` | "1.2" | The minimum supported TLS version for this Service Bus Namespace. Valid values are: 1.0, 1.1 and 1.2. Defaults to 1.2

#### Outputs
| Name | Description |
|------|-------------|
| resource | All attributes of the main object. |
| id | ServiceBus namespace ID. |
| name | ServiceBus namespace name. |
| drc | Disaster recovery config |
| drc_primary_connection | Disaster recovery config primary connection string |

#### How to use
There is a complete example inside the examples folder.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.90.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.90.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.servicebus-diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_servicebus_namespace.servicebus-namespace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) | resource |
| [azurerm_servicebus_namespace.servicebus-secondary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) | resource |
| [azurerm_servicebus_namespace_authorization_rule.servicebus-ns-auth-rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) | resource |
| [azurerm_servicebus_namespace_disaster_recovery_config.drc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_disaster_recovery_config) | resource |
| [azurerm_servicebus_namespace_network_rule_set.servicebus-network-rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_network_rule_set) | resource |
| [azurerm_servicebus_namespace_network_rule_set.servicebus-secondary-network-rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_network_rule_set) | resource |
| [azurerm_servicebus_queue.servicebus-queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) | resource |
| [azurerm_servicebus_queue_authorization_rule.servicebus-queue-auth-rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue_authorization_rule) | resource |
| [azurerm_servicebus_subscription.servicebus-subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription) | resource |
| [azurerm_servicebus_subscription_rule.servicebus-subscription-rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription_rule) | resource |
| [azurerm_servicebus_topic.servicebus-topic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic) | resource |
| [azurerm_servicebus_topic_authorization_rule.servicebus-topic-auth-rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic_authorization_rule) | resource |
| [random_string.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Specifies the capacity. When sku is Premium, capacity can be 1, 2, 4 or 8. When sku is Basic or Standard, capacity can be 0 only. | `number` | `0` | no |
| <a name="input_geo_recovery"></a> [geo\_recovery](#input\_geo\_recovery) | Service Bus Geo-DR Alias. | <pre>object({<br>    alias              = string<br>    secondary_location = string<br>  })</pre> | <pre>{<br>  "alias": "",<br>  "secondary_location": "North Europe"<br>}</pre> | no |
| <a name="input_infrastructure_encryption"></a> [infrastructure\_encryption](#input\_infrastructure\_encryption) | (Optional) Used to specify whether enable Infrastructure Encryption (Double Encryption). Changing this forces a new resource to be created. | `bool` | `false` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics ID for the Application Gateway | `string` | `""` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | (Optional) The minimum supported TLS version for this Service Bus Namespace. Valid values are: 1.0, 1.1 and 1.2. Defaults to 1.2 | `string` | `"1.2"` | no |
| <a name="input_namespace_authorization_rules"></a> [namespace\_authorization\_rules](#input\_namespace\_authorization\_rules) | Namespace authorization rules | `any` | `null` | no |
| <a name="input_naming"></a> [naming](#input\_naming) | The naming module output | `any` | n/a | yes |
| <a name="input_network_ip_rules"></a> [network\_ip\_rules](#input\_network\_ip\_rules) | One or more IP Addresses, or CIDR Blocks which should be able to access the ServiceBus Namespace. | `any` | `null` | no |
| <a name="input_network_rule_default_action"></a> [network\_rule\_default\_action](#input\_network\_rule\_default\_action) | Specifies the default action for the ServiceBus Namespace Network Rule Set. Possible values are Allow and Deny. Defaults to Deny. | `string` | `"Deny"` | no |
| <a name="input_network_subnet_rules"></a> [network\_subnet\_rules](#input\_network\_subnet\_rules) | Subnets that will be able to access ServiceBus | `any` | `null` | no |
| <a name="input_premium_messaging_partitions"></a> [premium\_messaging\_partitions](#input\_premium\_messaging\_partitions) | (Optional) Specifies the number messaging partitions. Only valid when sku is Premium and the minimum number is 1. Possible values include 0, 1, 2, and 4. Defaults to 0 for Standard, Basic namespace. Changing this forces a new resource to be created. | `number` | `0` | no |
| <a name="input_queue_authorization_rules"></a> [queue\_authorization\_rules](#input\_queue\_authorization\_rules) | Queue authorization rules | `any` | `null` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | Queues. | `any` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | n/a | `string` | `""` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The servicebus namespace Sku. It can be one of Basic, Standard or Premium. Defaults to Standard. | `string` | `"Standard"` | no |
| <a name="input_subscriptions"></a> [subscriptions](#input\_subscriptions) | Subscriptions inside topics. | `any` | `null` | no |
| <a name="input_topic_authorization_rules"></a> [topic\_authorization\_rules](#input\_topic\_authorization\_rules) | Topic authorization rules | `any` | `null` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | Topics. | `any` | `null` | no |
| <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant) | Whether or not this resource is zone redundant. sku needs to be Premium. Defaults to false. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_drc"></a> [drc](#output\_drc) | n/a |
| <a name="output_drc_primary_connection"></a> [drc\_primary\_connection](#output\_drc\_primary\_connection) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_resource"></a> [resource](#output\_resource) | n/a |
<!-- END_TF_DOCS -->