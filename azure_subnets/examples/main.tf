provider "azurerm" {
  features {}
}

module "naming" {
  source            = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.naming.git?ref=5.0"
  product_name      = "s00-wspace"
  product_iteration = "001"
  environment       = "dev"
  location          = "west europe"
  tags = {
    Chapter = "Networking"
    Domain  = "infra"
  }
}

module "rg" {
  source = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.resource_group.git?ref=5.0"
  naming = module.naming
}

module "vnet" {
  source                     = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.virtual_network.git?ref=5.0"
  naming                     = module.naming
  resource_group_name        = module.rg.name
  address_space              = ["192.168.1.0/24"]
  dns_servers                = ["1.1.1.1"]
  ddos_plan                  = module.naming.ddos_plan_dp_prd_id
  log_analytics_workspace_id = module.naming.dp_azlog
}

module "snets" {
  source              = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.subnets.git?ref=5.0"
  naming              = module.naming
  resource_group_name = module.rg.name
  vnet_name           = module.vnet.name
  subnets = [
    {
      name              = "subnet-1"                                                        # Required
      prefixes          = ["192.168.1.0/26"]                                                # Required
      delegations       = ["Microsoft.Web/serverFarms"]                                     # Optional 
      service_endpoints = ["Microsoft.Storage", "Microsoft.AzureCosmosDB", "Microsoft.Web"] # Optional 
      nsg_rules = [                                                                         # Optional 
        {
          name                       = "allow-http-from"
          priority                   = 101
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "TCP"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefixes    = flatten([module.naming.ips_cidr])
          destination_address_prefix = "*"
        },
        {
          name                       = "allow-https-from"
          priority                   = 102
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "TCP"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefixes    = flatten([module.naming.ips_cidr])
          destination_address_prefix = "*"
        },
      ]
    },
    {
      name        = "subnet-2"                    # Required
      prefixes    = ["192.168.1.64/26"]           # Required
      delegations = ["Microsoft.Web/serverFarms"] # Optional
    },
    {
      name              = "subnet-3"                                                        # Required
      prefixes          = ["192.168.1.128/26"]                                              # Required
      service_endpoints = ["Microsoft.Storage", "Microsoft.AzureCosmosDB", "Microsoft.Web"] # Optional
    }
  ]
}

output "all_module_outputs" {
  value = module.snets
}
