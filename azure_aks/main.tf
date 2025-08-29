resource "azurerm_kubernetes_cluster" "default" {
  name                             = var.cluster_name == null ? "${var.prefix}-aks" : var.cluster_name
  kubernetes_version               = var.kubernetes_version
  location                         = var.resource_group_location
  resource_group_name              = var.resource_group_name
  node_resource_group              = var.resource_group_name_managed
  dns_prefix                       = var.prefix
  sku_tier                         = var.sku_tier
  private_cluster_enabled          = var.private_cluster_enabled
  local_account_disabled           = var.local_account_disabled
  oidc_issuer_enabled              = var.oidc_issuer_enabled
  workload_identity_enabled        = var.workload_identity_enabled
  http_application_routing_enabled = var.http_application_routing_enabled
  tags                             = merge(var.tags, var.agents_tags)
  default_node_pool {
    orchestrator_version         = var.orchestrator_version
    name                         = var.agents_pool_name
    vm_size                      = var.agents_size
    os_disk_size_gb              = var.os_disk_size_gb
    vnet_subnet_id               = var.vnet_subnet_id
    enable_auto_scaling          = var.enable_auto_scaling
    node_count                   = var.enable_auto_scaling ? null : var.agents_count
    max_count                    = var.enable_auto_scaling ? var.agents_max_count : null
    min_count                    = var.enable_auto_scaling ? var.agents_min_count : null
    enable_node_public_ip        = var.enable_node_public_ip
    zones                        = var.agents_availability_zones
    node_labels                  = var.agents_labels
    type                         = var.agents_type
    tags                         = merge(var.tags, var.agents_tags)
    max_pods                     = var.agents_max_pods
    enable_host_encryption       = var.enable_host_encryption
    only_critical_addons_enabled = var.critical_addons_enabled
    upgrade_settings {
      drain_timeout_in_minutes      = var.drain_timeout_in_minutes
      node_soak_duration_in_minutes = var.node_soak_duration_in_minutes
      max_surge                     = var.max_surge
    }
  }

  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_node_os["enabled"] ? [1] : []

    content {
      frequency   = var.maintenance_node_os["frequency"]
      interval    = var.maintenance_node_os["interval"]
      duration    = var.maintenance_node_os["duration"]
      day_of_week = var.maintenance_node_os["day_of_week"]
      start_time  = var.maintenance_node_os["start_time"]
      utc_offset  = var.maintenance_node_os["utc_offset"]
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_node_os["enabled"] ? [1] : []

    content {
      allowed {
        day   = "Monday"
        hours = [9, 16]
      }
      allowed {
        day   = "Tuesday"
        hours = [9, 16]
      }
      allowed {
        day   = "Wednesday"
        hours = [9, 16]
      }
      allowed {
        day   = "Thursday"
        hours = [9, 16]
      }
    }
  }

  dynamic "service_principal" {
    for_each = var.client_id != "" && var.client_secret != "" ? ["service_principal"] : []
    content {
      client_id     = var.client_id
      client_secret = var.client_secret
    }
  }

  dynamic "api_server_access_profile" {
    for_each = var.api_server_authorized_ip_ranges != "" ? ["api_server_access_profile"] : []
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }
  dynamic "identity" {
    for_each = var.client_id == "" || var.client_secret == "" ? ["identity"] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? [var.user_assigned_identity_id] : null
    }
  }

  dynamic "kubelet_identity" {
    for_each = var.identity_type == "UserAssigned" ? ["kubelet_identity"] : []
    content {
      client_id                 = var.user_assigned_identity_client_id
      object_id                 = var.user_assigned_identity_object_id
      user_assigned_identity_id = var.user_assigned_identity_id
    }
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = var.enable_role_based_access_control
    managed                = true
    admin_group_object_ids = var.rbac_aad_admin_group_object_ids
  }

  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    dns_service_ip    = var.net_profile_dns_service_ip
    outbound_type     = var.enable_nat_gateway ? "managedNATGateway" : var.net_profile_outbound_type
    pod_cidr          = var.net_profile_pod_cidr
    service_cidr      = var.net_profile_service_cidr
    load_balancer_sku = "standard"
    dynamic "load_balancer_profile" {
      for_each = var.enable_outbund_public_ip == "loadBalancer" ? ["loadBalancer"] : []
      content {
        idle_timeout_in_minutes   = 5
        managed_outbound_ip_count = var.net_managed_outbound_ips
        outbound_ip_address_ids   = var.public_ip_id
      }
    }
    dynamic "nat_gateway_profile" {
      for_each = var.enable_nat_gateway ? ["nat_gateway"] : []
      content {
        idle_timeout_in_minutes   = 10
        managed_outbound_ip_count = var.nat_gateway_outbound_ip_count
      }
    }
  }
  dynamic "oms_agent" {
    for_each = var.enable_log_analytics_workspace ? ["oms_agent"] : []
    content {
      log_analytics_workspace_id = var.azurerm_log_analytics_workspace
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.enable_key_vault_secrets_provider ? ["key_vault"] : []
    content {
      secret_rotation_enabled  = false
      secret_rotation_interval = "2m"
    }
  }

  storage_profile {
    blob_driver_enabled         = var.blob_driver_enabled
    disk_driver_enabled         = var.disk_driver_enabled
    disk_driver_version         = var.disk_driver_version
    file_driver_enabled         = var.file_driver_enabled
    snapshot_controller_enabled = var.snapshot_controller_enabled
  }

  azure_policy_enabled = var.enable_azure_policy

  # <!-- BEGIN_META_ARGUMENT -->
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      default_node_pool.0.name,
      default_node_pool.0.vm_size,
      default_node_pool.0.zones,
      default_node_pool.0.tags,
      default_node_pool.0.node_count,
    ]
  }
  # <!-- END_META_ARGUMENT -->
}

resource "azurerm_kubernetes_cluster_node_pool" "nodepools" {
  for_each              = var.nodepools
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.default.id
  orchestrator_version  = var.orchestrator_version
  zones                 = each.value.availability_zones
  priority              = try(each.value.priority, "Regular")
  spot_max_price        = try(each.value.priority, "Regular") == "Spot" ? try(each.value.spot_max_price, "-1") : null
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count             = each.value.enable_auto_scaling ? each.value.max_count : null
  node_count            = each.value.node_count
  vnet_subnet_id        = azurerm_kubernetes_cluster.default.default_node_pool[0].vnet_subnet_id
  vm_size               = each.value.vm_size
  os_disk_size_gb       = each.value.os_disk_size_gb
  node_labels           = each.value.labels
  node_taints           = each.value.taints
  tags                  = var.tags

  dynamic "linux_os_config" {

    for_each = var.linux_os_config != null ? toset([each.value.name]) : []
    content {
      transparent_huge_page_defrag  = lookup(var.linux_os_config, "transparent_huge_page_defrag", "defer+madvise")
      transparent_huge_page_enabled = lookup(var.linux_os_config, "transparent_huge_page_enabled", "madvise")

      sysctl_config {
        fs_aio_max_nr                      = lookup(var.linux_os_config.sysctl_config, "fs_aio_max_nr", null)
        fs_file_max                        = lookup(var.linux_os_config.sysctl_config, "fs_file_max", 2097152)
        fs_inotify_max_user_watches        = lookup(var.linux_os_config.sysctl_config, "fs_inotify_max_user_watches", null)
        fs_nr_open                         = lookup(var.linux_os_config.sysctl_config, "fs_nr_open", null)
        kernel_threads_max                 = lookup(var.linux_os_config.sysctl_config, "kernel_threads_max", null)
        net_core_netdev_max_backlog        = lookup(var.linux_os_config.sysctl_config, "net_core_netdev_max_backlog", null)
        net_core_optmem_max                = lookup(var.linux_os_config.sysctl_config, "net_core_optmem_max", null)
        net_core_rmem_default              = lookup(var.linux_os_config.sysctl_config, "net_core_rmem_default", null)
        net_core_rmem_max                  = lookup(var.linux_os_config.sysctl_config, "net_core_rmem_max", null)
        net_core_somaxconn                 = lookup(var.linux_os_config.sysctl_config, "net_core_somaxconn", 32768)
        net_core_wmem_default              = lookup(var.linux_os_config.sysctl_config, "net_core_wmem_default", null)
        net_core_wmem_max                  = lookup(var.linux_os_config.sysctl_config, "net_core_wmem_max", null)
        net_ipv4_ip_local_port_range_max   = lookup(var.linux_os_config.sysctl_config, "net_ipv4_ip_local_port_range_max", 60999)
        net_ipv4_ip_local_port_range_min   = lookup(var.linux_os_config.sysctl_config, "net_ipv4_ip_local_port_range_min", 32768)
        net_ipv4_neigh_default_gc_thresh1  = lookup(var.linux_os_config.sysctl_config, "net_ipv4_neigh_default_gc_thresh1", null)
        net_ipv4_neigh_default_gc_thresh2  = lookup(var.linux_os_config.sysctl_config, "net_ipv4_neigh_default_gc_thresh2", null)
        net_ipv4_neigh_default_gc_thresh3  = lookup(var.linux_os_config.sysctl_config, "net_ipv4_neigh_default_gc_thresh3", null)
        net_ipv4_tcp_fin_timeout           = lookup(var.linux_os_config.sysctl_config, "net_ipv4_tcp_fin_timeout", null)
        net_ipv4_tcp_keepalive_intvl       = lookup(var.linux_os_config.sysctl_config, "net_ipv4_tcp_keepalive_intvl", null)
        net_ipv4_tcp_keepalive_probes      = lookup(var.linux_os_config.sysctl_config, "net_ipv4_tcp_keepalive_probes", null)
        net_ipv4_tcp_keepalive_time        = lookup(var.linux_os_config.sysctl_config, "net_ipv4_tcp_keepalive_time", null)
        net_ipv4_tcp_max_syn_backlog       = lookup(var.linux_os_config.sysctl_config, "net_ipv4_tcp_max_syn_backlog", null)
        net_ipv4_tcp_max_tw_buckets        = lookup(var.linux_os_config.sysctl_config, "net_ipv4_tcp_max_tw_buckets", null)
        net_ipv4_tcp_tw_reuse              = lookup(var.linux_os_config.sysctl_config, "net_ipv4_tcp_tw_reuse", true)
        net_netfilter_nf_conntrack_buckets = lookup(var.linux_os_config.sysctl_config, "net_netfilter_nf_conntrack_buckets", null)
        net_netfilter_nf_conntrack_max     = lookup(var.linux_os_config.sysctl_config, "net_netfilter_nf_conntrack_max", null)
        vm_max_map_count                   = lookup(var.linux_os_config.sysctl_config, "vm_max_map_count", 262144)
        vm_swappiness                      = lookup(var.linux_os_config.sysctl_config, "vm_swappiness", null)
        vm_vfs_cache_pressure              = lookup(var.linux_os_config.sysctl_config, "vm_vfs_cache_pressure", null)
      }
    }
  }

  # dynamic "upgrade_settings" {
  #   for_each = toset([each.value.name])
  #   content {
  #     drain_timeout_in_minutes      = var.drain_timeout_in_minutes
  #     max_surge                     = var.max_surge
  #     node_soak_duration_in_minutes = var.node_soak_duration_in_minutes
  #   }
  # }

  upgrade_settings {
      drain_timeout_in_minutes      = var.drain_timeout_in_minutes
      max_surge                     = var.max_surge
      node_soak_duration_in_minutes = var.node_soak_duration_in_minutes
  }


  # <!-- BEGIN_META_ARGUMENT -->
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      zones,
      node_count,
      tags,
    ]
  }

  depends_on = [azurerm_kubernetes_cluster.default]
  # <!-- END_META_ARGUMENT -->

}
