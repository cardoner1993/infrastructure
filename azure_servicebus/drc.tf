resource "random_string" "prefix" {
  count     = var.geo_recovery.alias == "" ? 0 : 1
  keepers   = { change = timestamp() }
  length    = 5
  lower     = true
  min_lower = 5
  numeric   = false
  special   = false
}

resource "azurerm_servicebus_namespace" "servicebus-secondary" {
  count                        = var.geo_recovery.alias == "" ? 0 : 1
  name                         = replace(var.naming.service_bus, "-sb-", "-sb-${random_string.prefix.0.result}-")
  location                     = var.geo_recovery.secondary_location
  resource_group_name          = length(var.resource_group) == 0 ? element(azurerm_resource_group.rg.*.name, 0) : var.resource_group
  sku                          = var.sku
  premium_messaging_partitions = var.sku == "Premium" ? 1 : 0
  capacity                     = var.capacity
  zone_redundant               = var.zone_redundant
  minimum_tls_version          = var.minimum_tls_version
  tags                         = var.naming.tags
  lifecycle {
    create_before_destroy = true
    # Add a precondition for validation
    precondition {
      condition = (
        var.sku == "Premium" && contains([1, 2, 4], var.premium_messaging_partitions)
      ) || (
        var.sku != "Premium" && var.premium_messaging_partitions == 0
      )
      error_message = "premium_messaging_partitions must be 0 for Basic or Standard SKU. For Premium SKU, it must be one of 1, 2 or 4."
    }
  }
}

resource "azurerm_servicebus_namespace_network_rule_set" "servicebus-secondary-network-rule" {
  count          = var.geo_recovery.alias == "" ? 0 : 1
  namespace_id   = azurerm_servicebus_namespace.servicebus-secondary.0.id
  default_action = var.network_rule_default_action
  ip_rules       = var.network_ip_rules
  dynamic "network_rules" {
    for_each = local.subnet_rules
    content {
      subnet_id                            = network_rules.value.subnet_id
      ignore_missing_vnet_service_endpoint = network_rules.value.ignore_missing_vnet_service_endpoint
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_servicebus_namespace_disaster_recovery_config" "drc" {
  count                = var.geo_recovery.alias == "" ? 0 : 1
  name                 = var.geo_recovery.alias
  primary_namespace_id = azurerm_servicebus_namespace.servicebus-namespace.id
  partner_namespace_id = azurerm_servicebus_namespace.servicebus-secondary.0.id
  depends_on = [
    azurerm_servicebus_namespace.servicebus-secondary.0,
    azurerm_servicebus_namespace_network_rule_set.servicebus-secondary-network-rule.0
  ]
}
