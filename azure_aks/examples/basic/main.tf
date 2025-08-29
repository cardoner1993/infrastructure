provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "aks-example-resource-group"
  location = "westeurope"
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.example.name
  vnet_name           = "aks-example-vnet"
  address_space       = "10.0.0.0/8"
  subnet_prefixes     = ["10.0.0.0/16"]
  subnet_names        = ["subnet1"]
  depends_on          = [azurerm_resource_group.example]
}

module "aks" {
  source                    = "../../"
  resource_group_name       = azurerm_resource_group.example.name
  resource_group_location   = azurerm_resource_group.example.location
  kubernetes_version        = "1.22.6"
  orchestrator_version      = "1.22.6"
  prefix                    = "prefix"
  cluster_name              = "example"
  network_plugin            = "azure"
  vnet_subnet_id            = module.network.vnet_subnets[0]
  os_disk_size_gb           = 50
  sku_tier                  = "Free" # defaults to Free
  agents_min_count          = 1
  agents_max_count          = 2
  agents_count              = 1
  agents_max_pods           = 100
  agents_pool_name          = "nodepool"
  agents_availability_zones = ["1"]
  agents_type               = "VirtualMachineScaleSets"

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  network_policy                 = "azure"
  net_profile_dns_service_ip     = "10.1.0.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.1.0.0/16"

  depends_on = [module.network]
}
