provider "azurerm" {
  features {
    resource_group { prevent_deletion_if_contains_resources = false }
  }
}

module "naming" {
  source            = "git::ssh://git@ssh.dev.azure.com/v3/.../TFMOD.azurerm.naming?ref=5.4"
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
  source = "git::ssh://git@ssh.dev.azure.com/v3/.../TFMOD.azurerm.resource_group?ref=5.0"
  naming = module.naming
}

module "vnet" {
  source              = "git::ssh://git@ssh.dev.azure.com/v3/.../TFMOD.azurerm.virtual_network?ref=5.0"
  naming              = module.naming
  resource_group_name = module.rg.name
  address_space       = ["192.168.1.0/24"]
}

module "subnets" {
  source              = "git::ssh://git@ssh.dev.azure.com/v3/.../TFMOD.azurerm.subnets?ref=5.0"
  naming              = module.naming
  resource_group_name = module.rg.name
  vnet_name           = module.vnet.name
  subnets = [
    {
      name              = module.naming.product_name
      prefixes          = ["192.168.1.0/24"]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.ContainerRegistry"]
      nsg_rules = [
        {
          name                       = "allow-ssh-from"
          priority                   = "101"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          description                = "SSH Inbound Access"
          source_address_prefixes    = flatten([module.naming.ips_cidr, module.naming.vpn_ips_cidr])
          destination_address_prefix = "*"
        },
        {
          name                       = "Inbound_BatchNodeManagement_29877"
          priority                   = "102"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "29877"
          description                = "Inbound_BatchNodeManagement_29877"
          source_address_prefix      = "BatchNodeManagement"
          destination_address_prefix = "VirtualNetwork"
        },
        {
          name                       = "Inbound_BatchNodeManagement_29876"
          priority                   = "103"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "29876"
          description                = "Inbound_BatchNodeManagement_29876"
          source_address_prefix      = "BatchNodeManagement"
          destination_address_prefix = "VirtualNetwork"
        }
      ]
    }
  ]
}

module "mlws" {
  source = "../"
  naming = module.naming
  network_rules = {
    allowed_subnets_ids = [module.subnets.subnets_ids.0]
    allowed_ips         = flatten([module.naming.ips_cidr, module.naming.vpn_ips, module.naming.adap_ips_cidr])
  }
  diagnositc_setings = false
}

module "mlcc" {
  source                        = "git::ssh://git@ssh.dev.azure.com/v3/.../TFMOD.azurerm.mlcc?ref=1.1"
  naming                        = module.naming
  machine_learning_workspace_id = module.mlws.id
  cluster_name                  = "pipelines"
  vm_priority                   = "Dedicated"
  vm_size                       = "STANDARD_DS1_V2"
  description                   = "This cluster is used to run all ml jobs/pipelines."
  scale_settings = {
    min_count      = 1
    max_count      = 2
    scale_duration = "PT2M"
  }
  subnet_resource_id = module.subnets.subnets_ids.0
}

output "all_ouputs" {
  value     = module.mlws
  sensitive = true
}
