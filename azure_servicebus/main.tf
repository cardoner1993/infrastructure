locals {
  resource_group = length(var.resource_group) == 0 ? var.naming.resource_group : 0
  ns_authorization_rules = var.namespace_authorization_rules == null ? {} : { for s in var.namespace_authorization_rules : s.name => {
    name   = s.name
    listen = try(s.listen, true)
    send   = try(s.send, true)
    manage = try(s.manage, false)
    }
  }
  queue_authorization_rules = var.queue_authorization_rules == null ? {} : { for s in var.queue_authorization_rules : s.name => {
    name       = s.name
    queue_name = s.queue_name
    listen     = try(s.listen, true)
    send       = try(s.send, true)
    manage     = try(s.manage, false)
    }
  }
  topic_authorization_rules = var.topic_authorization_rules == null ? {} : { for s in var.topic_authorization_rules : s.name => {
    name       = s.name
    topic_name = s.topic_name
    listen     = try(s.listen, true)
    send       = try(s.send, true)
    manage     = try(s.manage, false)
    }
  }
  subnet_rules = var.network_subnet_rules == null ? {} : { for s in var.network_subnet_rules : s.subnet_id => {
    subnet_id                            = s.subnet_id
    ignore_missing_vnet_service_endpoint = try(s.ignore_missing_vnet_service_endpoint, false)
    }
  }
  queues = var.queues == null ? {} : { for s in var.queues : s.name => {
    name                                    = s.name
    lock_duration                           = try(s.lock_duration, null)
    max_size_in_megabytes                   = try(s.max_size_in_megabytes, null)
    requires_duplicate_detection            = try(s.requires_duplicate_detection, null)
    requires_session                        = try(s.requires_session, null)
    default_message_ttl                     = try(s.default_message_ttl, null)
    dead_lettering_on_message_expiration    = try(s.dead_lettering_on_message_expiration, null)
    duplicate_detection_history_time_window = try(s.duplicate_detection_history_time_window, null)
    max_delivery_count                      = try(s.max_delivery_count, null)
    status                                  = try(s.status, null)
    enable_batched_operations               = try(s.enable_batched_operations, null)
    auto_delete_on_idle                     = try(s.auto_delete_on_idle, null)
    enable_partitioning                     = try(s.enable_partitioning, null)
    enable_express                          = try(s.enable_express, null)
    forward_to                              = try(s.forward_to, null)
    forward_dead_lettered_messages_to       = try(s.forward_dead_lettered_messages_to, null)
    }
  }
  subscriptions = var.subscriptions == null ? {} : { for s in var.subscriptions : s.name => {
    name                                      = s.name
    topic_name                                = s.topic_name
    max_delivery_count                        = try(s.max_delivery_count, 1)
    auto_delete_on_idle                       = try(s.auto_delete_on_idle, null)
    default_message_ttl                       = try(s.default_message_ttl, null)
    lock_duration                             = try(s.lock_duration, null)
    dead_lettering_on_message_expiration      = try(s.dead_lettering_on_message_expiration, false)
    dead_lettering_on_filter_evaluation_error = try(s.dead_lettering_on_filter_evaluation_error, true)
    enable_batched_operations                 = try(s.enable_batched_operations, false)
    requires_session                          = try(s.requires_session, false)
    forward_to                                = try(s.forward_to, null)
    forward_dead_lettered_messages_to         = try(s.forward_dead_lettered_messages_to, null)
    status                                    = try(s.status, "Active")
    sql_filter                                = try(s.sql_filter, "1=1")
    sql_filter_action                         = try(s.sql_filter_action, null)
    }
  }
  topics = var.topics == null ? {} : { for s in var.topics : s.name => {
    name                                    = s.name
    status                                  = try(s.status, "Active")
    auto_delete_on_idle                     = try(s.auto_delete_on_idle, null)
    default_message_ttl                     = try(s.default_message_ttl, null)
    duplicate_detection_history_time_window = try(s.duplicate_detection_history_time_window, null)
    enable_batched_operations               = try(s.enable_batched_operations, false)
    enable_express                          = try(s.enable_express, false)
    enable_partitioning                     = try(s.enable_partitioning, false)
    max_size_in_megabytes                   = try(s.max_size_in_megabytes, null)
    requires_duplicate_detection            = try(s.requires_duplicate_detection, false)
    support_ordering                        = try(s.support_ordering, false)
    max_message_size_in_kilobytes           = var.sku == "Premium" ? try(s.max_message_size_in_kilobytes, null) : null
    }
  }
}

resource "azurerm_resource_group" "rg" {
  count    = length(var.resource_group) == 0 ? 1 : 0
  name     = local.resource_group
  location = var.naming.location_name
  tags     = var.naming.tags
}

resource "azurerm_servicebus_namespace" "servicebus-namespace" {
  name                         = var.naming.service_bus
  location                     = var.naming.location_name
  resource_group_name          = length(var.resource_group) == 0 ? element(azurerm_resource_group.rg.*.name, 0) : var.resource_group
  sku                          = var.sku
  premium_messaging_partitions = var.sku == "Premium" ? 1 : 0
  minimum_tls_version          = var.minimum_tls_version
  capacity                     = var.capacity
  zone_redundant               = var.zone_redundant
  tags                         = var.naming.tags

  # Add a precondition for validation
  lifecycle {
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

resource "azurerm_servicebus_namespace_authorization_rule" "servicebus-ns-auth-rule" {
  for_each     = local.ns_authorization_rules
  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.servicebus-namespace.id
  listen       = each.value.listen
  send         = each.value.send
  manage       = each.value.manage
}

resource "azurerm_servicebus_namespace_network_rule_set" "servicebus-network-rule" {
  namespace_id   = azurerm_servicebus_namespace.servicebus-namespace.id
  default_action = var.network_rule_default_action
  ip_rules       = var.network_ip_rules
  dynamic "network_rules" {
    for_each = local.subnet_rules
    content {
      subnet_id                            = network_rules.value.subnet_id
      ignore_missing_vnet_service_endpoint = network_rules.value.ignore_missing_vnet_service_endpoint
    }
  }
}

resource "azurerm_servicebus_queue" "servicebus-queue" {
  for_each                                = local.queues
  name                                    = each.value.name
  namespace_id                            = azurerm_servicebus_namespace.servicebus-namespace.id
  lock_duration                           = each.value.lock_duration
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  requires_session                        = each.value.requires_session
  default_message_ttl                     = each.value.default_message_ttl
  dead_lettering_on_message_expiration    = each.value.dead_lettering_on_message_expiration
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  max_delivery_count                      = each.value.max_delivery_count
  status                                  = each.value.status
  enable_batched_operations               = each.value.enable_batched_operations
  auto_delete_on_idle                     = each.value.auto_delete_on_idle
  enable_partitioning                     = each.value.enable_partitioning
  enable_express                          = each.value.enable_express
  forward_to                              = each.value.forward_to
  forward_dead_lettered_messages_to       = each.value.forward_dead_lettered_messages_to
}

resource "azurerm_servicebus_queue_authorization_rule" "servicebus-queue-auth-rule" {
  for_each = local.queue_authorization_rules
  name     = each.value.name
  queue_id = azurerm_servicebus_queue.servicebus-queue[each.value.queue_name].id
  listen   = each.value.listen
  send     = each.value.send
  manage   = each.value.manage
}

resource "azurerm_servicebus_subscription" "servicebus-subscription" {
  for_each                                  = local.subscriptions
  name                                      = each.value.name
  topic_id                                  = azurerm_servicebus_topic.servicebus-topic[each.value.topic_name].id
  max_delivery_count                        = each.value.max_delivery_count
  auto_delete_on_idle                       = each.value.auto_delete_on_idle
  default_message_ttl                       = each.value.default_message_ttl
  lock_duration                             = each.value.lock_duration
  dead_lettering_on_message_expiration      = each.value.dead_lettering_on_message_expiration
  dead_lettering_on_filter_evaluation_error = each.value.dead_lettering_on_filter_evaluation_error
  enable_batched_operations                 = each.value.enable_batched_operations
  requires_session                          = each.value.requires_session
  forward_to                                = each.value.forward_to
  forward_dead_lettered_messages_to         = each.value.forward_dead_lettered_messages_to
  status                                    = each.value.status
}

resource "azurerm_servicebus_subscription_rule" "servicebus-subscription-rule" {
  for_each        = local.subscriptions
  name            = "${each.value.name}-rule"
  subscription_id = azurerm_servicebus_subscription.servicebus-subscription[each.value.name].id
  filter_type     = "SqlFilter"
  sql_filter      = each.value.sql_filter
  action          = each.value.sql_filter_action
  depends_on = [
    azurerm_servicebus_subscription.servicebus-subscription
  ]
}

resource "azurerm_servicebus_topic" "servicebus-topic" {
  for_each                                = local.topics
  name                                    = each.value.name
  namespace_id                            = azurerm_servicebus_namespace.servicebus-namespace.id
  status                                  = each.value.status
  auto_delete_on_idle                     = each.value.auto_delete_on_idle
  default_message_ttl                     = each.value.default_message_ttl
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  enable_batched_operations               = each.value.enable_batched_operations
  enable_express                          = each.value.enable_express
  enable_partitioning                     = each.value.enable_partitioning
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  support_ordering                        = each.value.support_ordering
  max_message_size_in_kilobytes           = each.value.max_message_size_in_kilobytes
}

resource "azurerm_servicebus_topic_authorization_rule" "servicebus-topic-auth-rule" {
  for_each = local.topic_authorization_rules
  name     = each.value.name
  topic_id = azurerm_servicebus_topic.servicebus-topic[each.value.topic_name].id
  listen   = each.value.listen
  send     = each.value.send
  manage   = each.value.manage
}

resource "azurerm_monitor_diagnostic_setting" "servicebus-diagnostics" {
  count              = length(var.log_analytics_workspace_id) == 0 ? 0 : 1
  name               = "diagsettingssb"
  target_resource_id = azurerm_servicebus_namespace.servicebus-namespace.id

  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "OperationalLogs"

    retention_policy {
      enabled = false
      days    = 180
    }
  }
}
