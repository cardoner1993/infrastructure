output "aks_id" {
  description = "Azure Kubernetes resource identifier."
  value       = azurerm_kubernetes_cluster.default.id
  sensitive   = false
}

output "kube_config" {
  description = "Azure Kubernetes kube config."
  value       = azurerm_kubernetes_cluster.default.kube_config.0
  sensitive   = true
}

output "kube_config_raw" {
  description = "Azure Kubernetes kube config file."
  value       = azurerm_kubernetes_cluster.default.kube_config_raw
  sensitive   = true
}

output "kubelet_identity" {
  description = "A kubelet_identity block as defined below."
  value       = azurerm_kubernetes_cluster.default.kubelet_identity
  sensitive   = true
}

output "location" {
  description = "Kubernetes default location resource group."
  value       = azurerm_kubernetes_cluster.default.location
  sensitive   = false
}

output "oidc_issuer_url" {
  value     = azurerm_kubernetes_cluster.default.oidc_issuer_url
  sensitive = false
}

output "node_resource_group" {
  value     = azurerm_kubernetes_cluster.default.node_resource_group
  sensitive = false
}