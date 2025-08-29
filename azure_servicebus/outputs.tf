output "resource" { value = azurerm_servicebus_namespace.servicebus-namespace }
output "id" { value = azurerm_servicebus_namespace.servicebus-namespace.id }
output "name" { value = azurerm_servicebus_namespace.servicebus-namespace.name }
output "drc" { value = var.geo_recovery.alias == "" ? [] : azurerm_servicebus_namespace_disaster_recovery_config.drc }
output "drc_primary_connection" { value = var.geo_recovery.alias == "" ? "" : azurerm_servicebus_namespace_disaster_recovery_config.drc.0.primary_connection_string_alias }
