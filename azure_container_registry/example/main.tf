module "naming" {
  source            = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.naming?ref=5.4"
  product_name      = "example"
  product_iteration = "001"
  environment       = "stg"
  location          = "west europe"
  tags = {
    Chapter = "DataOps"
    Domain  = "dp"
  }
}

module "rg" {
  source = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.resource_group?ref=5.0"
  naming = module.naming
}

module "acr" {
  source         = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.container_registry?ref=4.2"
  naming         = module.naming
  resource_group = module.rg.name
  sku            = var.sku
  admin_enabled  = true
  env            = var.env


  georeplication_locations = [
    {
      location                  = "North Europe"
      zone_redundancy_enabled   = true
      regional_endpoint_enabled = true
      tags = {
        env = var.env
      }
    }
  ]

  ip_rules               = flatten([module.naming.ips_cidr, module.naming.vpn_ips, module.naming.adap_ips_cidr, var.ip_rules])
  virtual_network_rules  = try(var.virtual_network_rules, [])
  network_default_access = "Deny"
  identities             = [
        {
                type = "UserAssigned"
                identity_ids = ["/subscriptions/.../resourcegroups/example-rg-stg-we-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/example-mi-stg-we-001"]
        }
  ]
}
