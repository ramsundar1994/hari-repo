# providers information
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.71.0"
    }
  }
}
provider "azurerm" {
  features {}
  client_id     = "a66a247e-c5e7-4a36-93be-fe5884d833f9"
  client_secret = ""
  tenant_id     = "4da0c7c8-386d-4699-b2d6-1bf91c67ed24"
  subscription_id = "48662256-1551-4a3d-8e37-335744834f2e"
}