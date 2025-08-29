resource "azurerm_resource_group" "rg" {
  count    = length(var.resource_group) == 0 ? 1 : 0
  name     = local.resource_group
  location = var.naming.location_name
  tags     = var.naming.tags
}

locals {
  resource_group         = length(var.resource_group) == 0 ? var.naming.resource_group : 0
  stg_allowed_ips        = [for ip in var.network_rules.allowed_ips : try(split("/", ip)[1] > 30, false) ? split("/", ip)[0] : ip]
  default_datastore_name = "workspaceblobstore"
  resource_group_name    = length(var.resource_group) == 0 ? element(azurerm_resource_group.rg.*.name, 0) : var.resource_group
}

data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "azlog" {
  count               = var.diagnositc_setings ? 1 : 0
  name                = "dpinf-monitor-azlog-${var.naming.environment}-we-002"
  resource_group_name = "dpinf-monitor-rg-${var.naming.environment}-we-002"
}

resource "azurerm_application_insights" "insights" {
  name                = replace(var.naming.ml_workspace, "mlws", "mlws-insights")
  location            = var.naming.location_name
  resource_group_name = local.resource_group_name
  application_type    = "web"
  tags                = var.naming.tags
  workspace_id        = var.diagnositc_setings ? data.azurerm_log_analytics_workspace.azlog.0.id : null
}

resource "azurerm_storage_account" "stg" {
  name                            = replace(replace(var.naming.ml_workspace, "mlws", "mlwsstg"), "-", "")
  resource_group_name             = local.resource_group_name
  location                        = var.naming.location_name
  account_tier                    = "Standard"
  min_tls_version                 = "TLS1_2"
  account_replication_type        = "GRS"
  allow_nested_items_to_be_public = false

  network_rules {
    default_action             = "Deny"
    ip_rules                   = local.stg_allowed_ips
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = flatten([var.network_rules.allowed_subnets_ids, var.naming.adap_dp_subnet_id])
    # private_link_access {
    #   endpoint_resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourcegroups/${local.resource_group}/providers/Microsoft.MachineLearningServices/workspaces/${var.naming.ml_workspace}"
    #   endpoint_tenant_id   = data.azurerm_client_config.current.tenant_id
    # }
  }

  blob_properties {
    cors_rule {
      allowed_headers    = ["*", ]
      allowed_methods    = ["GET", "HEAD", ]
      allowed_origins    = ["https://mlworkspace.azure.ai", "https://ml.azure.com", "https://*.ml.azure.com", ]
      exposed_headers    = ["*", ]
      max_age_in_seconds = 1800
    }
  }

  identity { type = "SystemAssigned" }

  tags = var.naming.tags

  lifecycle {
    ignore_changes = [
      tags["LastRotationDate"]
    ]
  }
}

resource "azurerm_container_registry" "acr" {
  name                       = replace(replace(var.naming.ml_workspace, "mlws", "mlwsacr"), "-", "")
  location                   = var.naming.location_name
  resource_group_name        = local.resource_group_name
  sku                        = "Premium"
  admin_enabled              = true
  network_rule_bypass_option = "AzureServices" # mandatory for azure machine learning workspaces

  network_rule_set {
    default_action  = "Deny"
    ip_rule         = [for ip in var.network_rules.allowed_ips : { action = "Allow", ip_range = length(split("/", ip)) > 1 ? ip : "${ip}/32" }]
    virtual_network = [for snet in var.network_rules.allowed_subnets_ids : { action = "Allow", subnet_id = snet }]
  }

  identity { type = "SystemAssigned" }

  tags = var.naming.tags
}

resource "azurerm_key_vault" "kv" {
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  name                            = replace(replace(var.naming.ml_workspace, "mlws", "mlwskv"), "-", "")
  location                        = var.naming.location_name
  resource_group_name             = local.resource_group_name
  sku_name                        = "standard"
  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  purge_protection_enabled        = false

  network_acls {
    bypass                     = "AzureServices" # mandatory for azure machine learning workspaces
    default_action             = "Deny"
    ip_rules                   = var.network_rules.allowed_ips
    virtual_network_subnet_ids = var.network_rules.allowed_subnets_ids
  }

  tags = var.naming.tags
}

resource "azurerm_key_vault_access_policy" "policy" {
  key_vault_id            = azurerm_key_vault.kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azurerm_client_config.current.object_id
  certificate_permissions = []
  key_permissions         = []
  secret_permissions      = ["Set", "Delete", "Get", "List", "Purge"]
  storage_permissions     = ["Set", "Delete", "Get", "List"]
}

resource "azurerm_machine_learning_workspace" "mlws" {
  name                          = var.naming.ml_workspace
  location                      = var.naming.location_name
  resource_group_name           = local.resource_group_name
  storage_account_id            = azurerm_storage_account.stg.id
  application_insights_id       = azurerm_application_insights.insights.id
  key_vault_id                  = azurerm_key_vault.kv.id
  container_registry_id         = azurerm_container_registry.acr.id
  image_build_compute_name      = "build"
  public_network_access_enabled = true
  high_business_impact          = false

  identity { type = "SystemAssigned" }

  tags = var.naming.tags

}

resource "azurerm_machine_learning_compute_cluster" "build" {
  name                          = "build"
  location                      = var.naming.location_name
  machine_learning_workspace_id = azurerm_machine_learning_workspace.mlws.id
  vm_priority                   = "Dedicated"
  vm_size                       = "STANDARD_DS5_V2"
  description                   = "Image build compute cluster"
  subnet_resource_id            = var.network_rules.allowed_subnets_ids.0
  ssh_public_access_enabled     = var.ssh.admin != "" ? true : false

  dynamic "ssh" {
    for_each = var.ssh.admin != "" ? toset([1]) : toset([])
    content {
      admin_username = var.ssh.admin
      key_value      = var.ssh.key_value
    }
  }

  scale_settings {
    min_node_count                       = 0
    max_node_count                       = 1
    scale_down_nodes_after_idle_duration = "PT2M"
  }

  identity { type = "SystemAssigned" }

  tags = var.naming.tags
}

######################
# Datastore Creation #
######################

resource "azurerm_storage_container" "aml_datastore_container" {
  for_each             = { for idx, value in var.azuerml_datastore : value => idx }
  name                 = "${replace(each.key, "_", "-")}"
  storage_account_name = azurerm_storage_account.stg.name
  container_access_type = "private"
}

resource "azurerm_machine_learning_datastore_blobstorage" "aml_datastore" {
  for_each                   = { for idx, value in var.azuerml_datastore : value => idx }
  workspace_id               = azurerm_machine_learning_workspace.mlws.id
  name                       = each.key
  storage_container_id       = azurerm_storage_container.aml_datastore_container[each.key].resource_manager_id
  account_key                = azurerm_storage_account.stg.primary_access_key
  service_data_auth_identity = "WorkspaceSystemAssignedIdentity"
  depends_on                 = [azurerm_storage_container.aml_datastore_container]
}