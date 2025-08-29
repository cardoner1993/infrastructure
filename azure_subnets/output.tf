output "resource" {
  value     = azurerm_subnet.subnets
  sensitive = false
}
output "subnets_names" {
  value     = [for item in azurerm_subnet.subnets : item.name]
  sensitive = false
}
output "subnets_ids" {
  value     = [for item in azurerm_subnet.subnets : item.id]
  sensitive = false
}
output "nsgs" {
  value     = azurerm_network_security_group.nsgs
  sensitive = false
}
output "nsgs_associations" {
  value     = azurerm_subnet_network_security_group_association.nsgs_associations
  sensitive = false
}
output "nsgs_rules" {
  value     = azurerm_network_security_rule.rules
  sensitive = false
}
output "nsgs_ids" {
  value     = [for item in azurerm_network_security_group.nsgs : item.id]
  sensitive = false
}
