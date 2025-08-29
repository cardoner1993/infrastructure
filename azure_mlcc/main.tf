resource "azurerm_machine_learning_compute_cluster" "mlcc" {
  name                          = var.cluster_name
  location                      = var.location == "" ? var.naming.location_name : var.location
  machine_learning_workspace_id = var.machine_learning_workspace_id
  vm_priority                   = var.vm_priority
  vm_size                       = upper(var.vm_size)
  subnet_resource_id            = var.subnet_resource_id
  description                   = var.description
  ssh_public_access_enabled     = var.ssh.admin != "" ? true : false

  dynamic "ssh" {
    for_each = var.ssh.admin != "" ? toset([1]) : toset([])
    content {
      admin_username = var.ssh.admin
      key_value      = var.ssh.key_value
    }
  }

  scale_settings {
    min_node_count                       = var.scale_settings.min_count
    max_node_count                       = var.scale_settings.max_count
    scale_down_nodes_after_idle_duration = var.scale_settings.scale_duration
  }

  identity {
    type         = var.identity_ids == [] ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids == [] ? null : var.identity_ids
  }

  tags = var.naming.tags
}
