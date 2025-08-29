locals {
  resource_group = length(var.resource_group) == 0 ? var.naming.resource_group : 0
  ip_rules = [for s in var.ip_rules : {
    action   = "Allow"
    ip_range = s
  }]
  virtual_network_rules = [for n in var.virtual_network_rules : {
    action    = "Allow"
    subnet_id = n
  }]
}

resource "azurerm_resource_group" "rg" {
  count    = length(var.resource_group) == 0 ? 1 : 0
  name     = local.resource_group
  location = var.naming.location_name
  tags     = var.naming.tags
}

resource "azurerm_container_registry" "acr" {
  name                = var.naming.acr
  location            = var.naming.location_name
  resource_group_name = length(var.resource_group) == 0 ? element(azurerm_resource_group.rg.*.name, 0) : var.resource_group
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  dynamic "georeplications" {
    for_each = var.georeplication_locations != null && var.sku == "Premium" && var.env == "prd" ? var.georeplication_locations : []
    content {
      location                  = try(georeplications.value.location, georeplications.value)
      zone_redundancy_enabled   = try(georeplications.value.zone_redundancy_enabled, null)
      regional_endpoint_enabled = try(georeplications.value.regional_endpoint_enabled, null)
      tags                      = try(georeplications.value.tags, null)
    }
  }

  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" ? [1] : []
    content {
      default_action  = var.network_default_access
      ip_rule         = local.ip_rules
      virtual_network = local.virtual_network_rules
    }
  }

  dynamic "identity" {
    for_each = var.identities
    iterator = rules
    content {
      type = rules.value.type
      identity_ids = rules.value.identity_ids
    }
  }

  tags = var.naming.tags
}

resource "azurerm_monitor_diagnostic_setting" "acr-diagnostics" {
  count                      = length(var.acr_log_analytics_workspace_id) == 0 ? 0 : 1
  name                       = "diag2law"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.acr_log_analytics_workspace_id
  enabled_log {
    category = "ContainerRegistryRepositoryEvents"

    retention_policy {
      enabled = false
      days    = 180
    }
  }
  enabled_log {
    category = "ContainerRegistryLoginEvents"

    retention_policy {
      enabled = false
      days    = 180
    }
  }
}
