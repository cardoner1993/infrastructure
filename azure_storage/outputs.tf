output "resource" {
  description = "The storage account resource"
  value       = azurerm_storage_account.stg
  sensitive   = true
}

output "name" {
  description = "The storage account name"
  value       = azurerm_storage_account.stg.name
  sensitive   = false
}

output "id" {
  description = "The storage account ID"
  value       = azurerm_storage_account.stg.id
  sensitive   = false
}

output "connection_string" {
  description = "The storage account connection string"
  value       = azurerm_storage_account.stg.primary_connection_string
  sensitive   = true
}

output "access_key" {
  description = "The storage account access key"
  value       = var.shared_access_key_enabled == true ? azurerm_storage_account.stg.primary_access_key : null
  sensitive   = true
}

