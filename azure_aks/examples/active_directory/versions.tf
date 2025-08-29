terraform {
  required_version = "v1.0.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.97.0"
    }
  }
  backend "azurerm" {}
}
