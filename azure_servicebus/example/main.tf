provider "azurerm" {
  features {
    resource_group { prevent_deletion_if_contains_resources = false }
  }
}

module "naming" {
  source            = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.naming?ref=5.1"
  product_name      = "example-lzmsg"
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

module "vnet" {
  source              = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.virtual_network?ref=5.0"
  naming              = module.naming
  resource_group_name = module.rg.name
  address_space       = ["192.168.1.0/24"]
}

module "subnets" {
  source              = "git::ssh://git@ssh.dev.azure.com/.../TFMOD.azurerm.subnets?ref=5.0"
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
          source_address_prefixes    = flatten([module.naming.ips_cidr])
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

module "lz_service_bus" {
  source               = "../"
  naming               = module.naming
  resource_group       = module.rg.name
  network_subnet_rules = [{ subnet_id = "${module.subnets.subnets_ids.0}", ignore_missing_vnet_service_endpoint = true }]
  network_ip_rules     = flatten([module.naming.ips])
  sku                  = "Premium"
  capacity             = 1
  geo_recovery = {
    alias              = "failover-${module.naming.product_name}"
    secondary_location = "north europe"
  }
  topics = [
    { name = "example_topic" },
    { name = "example_topic_max_msg_size_kb", max_message_size_in_kilobytes = 2048 }
  ]
  topic_authorization_rules = [
    {
      name       = "devops-auth"
      topic_name = "example_topic"
      send       = true
      listen     = true
      manage     = false
    }
  ]
  subscriptions = [
    {
      name       = "example-topic-subscriber-PT"
      sql_filter = "country='PT'"
      topic_name = "example_topic"
    }
  ]
}

output "all_ouputs" {
  value     = module.lz_service_bus
  sensitive = true
}
