locals {
  subnets = { for item in var.subnets : replace(item.name, " ", "-") =>
    {
      snet_name                          = replace(item.name, " ", "-")
      nsg_name                           = try(replace(var.naming.nsg, var.naming.product_name, item.name), "none")
      prefixes                           = item.prefixes
      route_table_id                     = try(item.route_table_id, null)
      service_endpoints                  = try(item.service_endpoints, [])
      private_endpoints                  = try(item.private_endpoints, false)
      private_endpoints_network_policies = try(item.private_endpoints_network_policies, "Disabled")
      nsg_rules = try([for rule in item.nsg_rules : {
        k_rule = "${replace(var.naming.nsg, var.naming.product_name, item.name)}-rule-${index(item.nsg_rules, rule)}"
        v_rule = {
          nsg_name                     = replace(var.naming.nsg, var.naming.product_name, item.name)
          priority                     = rule.priority
          direction                    = rule.direction
          access                       = rule.access
          protocol                     = rule.protocol
          source_port_range            = try(rule.source_port_range, null)
          source_port_ranges           = try(rule.source_port_ranges, null)
          destination_port_range       = try(rule.destination_port_range, null)
          destination_port_ranges      = try(rule.destination_port_ranges, null)
          source_address_prefix        = try(rule.source_address_prefix, null)
          source_address_prefixes      = try(rule.source_address_prefixes, null)
          destination_address_prefix   = try(rule.destination_address_prefix, null)
          destination_address_prefixes = try(rule.destination_address_prefixes, null)
          description                  = "${replace(var.naming.nsg, var.naming.product_name, item.name)}-rule-${index(item.nsg_rules, rule)}"
        }
        }
      ], [])
      delegations = try([
        for delegation in item.delegations : {
          name = lower(split("/", delegation)[1])
          service_delegation = {
            name    = delegation
            actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
          }
        }
      ], [])
    }
  }

  nsgs_rules_build  = flatten([for snet in local.subnets : [for rule in snet.nsg_rules : rule]])
  nsgs              = toset([for item in local.subnets : item.nsg_name if item.nsg_name != "none"])
  nsgs_rules        = { for rule in local.nsgs_rules_build : rule.k_rule => rule.v_rule }
  nsgs_associations = { for item in local.subnets : item.snet_name => item.nsg_name if item.nsg_name != "none" }

}

resource "azurerm_network_security_group" "nsgs" {
  for_each            = local.nsgs
  name                = each.key
  location            = var.naming.location_name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_subnet.subnets]
}

resource "azurerm_network_security_rule" "rules" {
  for_each                     = local.nsgs_rules
  resource_group_name          = var.resource_group_name
  network_security_group_name  = each.value.nsg_name
  name                         = each.key
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = each.value.source_port_range
  source_port_ranges           = each.value.source_port_ranges
  destination_port_range       = each.value.destination_port_range
  destination_port_ranges      = each.value.destination_port_ranges
  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
  description                  = each.value.description
  depends_on                   = [azurerm_network_security_group.nsgs]
}

resource "azurerm_subnet" "subnets" {
  for_each                                      = local.subnets
  virtual_network_name                          = var.vnet_name
  resource_group_name                           = var.resource_group_name
  name                                          = each.key
  address_prefixes                              = each.value.prefixes
  service_endpoints                             = each.value.service_endpoints
  private_link_service_network_policies_enabled = each.value.private_endpoints
  private_endpoint_network_policies             = each.value.private_endpoints_network_policies

  dynamic "delegation" {
    for_each = each.value.delegations
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }

}

resource "azurerm_subnet_network_security_group_association" "nsgs_associations" {
  for_each                  = local.nsgs_associations
  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsgs[each.value].id
  depends_on                = [azurerm_network_security_group.nsgs, azurerm_subnet.subnets]
}
