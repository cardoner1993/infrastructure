/**
 * # Azure Storage Account Module
 *
 * This module deploys an Azure Storage Account.
 */
locals {
  account_tier             = (var.kind == "FileStorage" ? "Premium" : split("_", var.sku)[0])
  account_replication_type = (local.account_tier == "Premium" ? "LRS" : split("_", var.sku)[1])
  shares                   = var.shares == null ? {} : { for s in var.shares : s.name => { name = s.name, quota = s.quota } }
  pitr_enabled = (
    alltrue([var.storage_blob_data_protection.change_feed_enabled, var.storage_blob_data_protection.versioning_enabled, var.storage_blob_data_protection.container_point_in_time_restore])
    && var.storage_blob_data_protection.delete_retention_policy_in_days > 0
    && var.storage_blob_data_protection.container_delete_retention_policy_in_days > 2
    && !(var.sftp_enabled)
  )
}

#TODO: add nfsv3_enabled
resource "azurerm_storage_account" "stg" {
  name                            = var.naming.storage_account
  resource_group_name             = var.resource_group_name
  location                        = var.naming.location_name
  account_kind                    = var.kind
  account_tier                    = local.account_tier
  account_replication_type        = local.account_replication_type
  min_tls_version                 = "TLS1_2"
  access_tier                     = var.access_tier
  https_traffic_only_enabled      = var.https_traffic_only_enabled
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  is_hns_enabled                  = var.is_hns_enabled
  shared_access_key_enabled       = var.shared_access_key_enabled
  large_file_share_enabled        = var.kind != "BlockBlobStorage" && contains(["LRS", "ZRS"], local.account_replication_type)
  sftp_enabled                    = var.sftp_enabled
  tags                            = var.naming.tags

  ######################
  # CUSTOM DOMAIN NAME #
  ######################
  dynamic "custom_domain" {
    for_each = var.custom_domain_name != null ? ["enabled"] : []
    content {
      name          = var.custom_domain_name
      use_subdomain = var.use_subdomain
    }
  }
  ############
  # IDENTITY #
  ############
  dynamic "identity" {
    for_each = var.identity_type == null ? [] : ["enabled"]
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids == "UserAssigned" ? var.identity_ids : null
    }
  }
  #############################
  # RETENTION POLICY FOR BLOB #
  #############################

  #TODO: Add queue_properties, share_properties and azure_files_authentication
  dynamic "blob_properties" {
    for_each = (
      var.kind != "FileStorage" && (var.storage_blob_data_protection != null) ? ["enabled"] : []
    )

    content {
      change_feed_enabled = var.sftp_enabled ? false : var.storage_blob_data_protection.change_feed_enabled
      versioning_enabled  = var.sftp_enabled ? false : var.storage_blob_data_protection.versioning_enabled

      dynamic "delete_retention_policy" {
        for_each = var.storage_blob_data_protection.delete_retention_policy_in_days > 0 ? ["enabled"] : []
        content {
          days = var.storage_blob_data_protection.delete_retention_policy_in_days
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = var.storage_blob_data_protection.container_delete_retention_policy_in_days > 0 ? ["enabled"] : []
        content {
          days = var.storage_blob_data_protection.container_delete_retention_policy_in_days
        }
      }

      dynamic "restore_policy" {
        for_each = local.pitr_enabled ? ["enabled"] : []
        content {
          days = var.storage_blob_data_protection.container_delete_retention_policy_in_days - 1
        }
      }
    }
  }


  #################
  # NETWORK RULES #
  #################
  dynamic "network_rules" {
    for_each = length(var.allowed_ips) != 0 || length(var.allowed_subnets_ids) != 0 ? ["enabled"] : []
    # for_each = var.allowed_ips != [] || var.allowed_subnets_ids != [] ? ["enabled"] : []
    content {
      default_action             = "Deny"
      bypass                     = var.network_bypass
      ip_rules                   = var.allowed_ips
      virtual_network_subnet_ids = var.allowed_subnets_ids
    }
  }


  ##################
  # STATIC WEBSITE #
  ##################
  dynamic "static_website" {
    for_each = var.enable_static_website == null ? [] : ["enabled"]
    content {
      index_document     = "index.html"
      error_404_document = "404.html"
    }
  }
}

#TODO: Add ACLs for azurerm_storage_container, azurerm_storage_queue and azurerm_storage_table
resource "azurerm_storage_container" "containers" {
  for_each              = { for v in var.containers : v => v }
  name                  = each.value
  storage_account_name  = azurerm_storage_account.stg.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.stg] #? Maybe not needed
}

resource "azurerm_storage_queue" "queues" {
  for_each             = { for v in var.queues : v => v }
  name                 = each.value
  storage_account_name = azurerm_storage_account.stg.name
  depends_on           = [azurerm_storage_account.stg] #? Maybe not needed
}

resource "azurerm_storage_table" "tables" {
  for_each             = { for v in var.tables : v => v }
  name                 = each.value
  storage_account_name = azurerm_storage_account.stg.name
  depends_on           = [azurerm_storage_account.stg] #? Maybe not needed
}

resource "azurerm_storage_share" "shares" {
  for_each             = local.shares
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.stg.name
  quota                = each.value.quota
}


resource "azurerm_storage_management_policy" "lcpolicy" {
  count              = length(var.storage_management_lifecycles) == 0 ? 0 : 1
  storage_account_id = azurerm_storage_account.stg.id
  dynamic "rule" {
    for_each = var.storage_management_lifecycles
    iterator = rule
    content {
      name    = try(rule.value.name, "rule-${rule.key}")
      enabled = try(tobool(rule.value.enabled), false)
      filters {
        prefix_match = rule.value.prefix_match
        blob_types   = ["blockBlob"]
        dynamic "match_blob_index_tag" {
          for_each = rule.value.tags_to_apply
          iterator = tag
          content {
            name      = tag.value.name
            operation = tag.value.operation
            value     = tag.value.value
          }
        }
      }
      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = try(length(rule.value.tier_to_cool_after_days) != 0 ? tonumber(rule.value.tier_to_cool_after_days) : null, null)
          tier_to_archive_after_days_since_modification_greater_than = try(length(rule.value.tier_to_archive_after_days) != 0 ? tonumber(rule.value.tier_to_archive_after_days) : null, null)
          delete_after_days_since_modification_greater_than          = try(length(rule.value.delete_after_days) != 0 ? tonumber(rule.value.delete_after_days) : null, null)
        }
      }
    }
  }
}
