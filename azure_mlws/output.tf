output "object" { value = azurerm_machine_learning_workspace.mlws }
output "name" { value = azurerm_machine_learning_workspace.mlws.name }
output "id" { value = azurerm_machine_learning_workspace.mlws.id }
output "insights_instrumentation_key" {
  value     = azurerm_application_insights.insights.instrumentation_key
  sensitive = true
}
output "storage" {
  value     = azurerm_storage_account.stg
  sensitive = true
}
output "kv_id" { value = azurerm_key_vault.kv.id }
output "log_analytics_workspace" {
  value     = var.diagnositc_setings ? data.azurerm_log_analytics_workspace.azlog.0 : null
  sensitive = true
}
