#Terraform function lowercase string ( )
resource "azurerm_resource_group" "rg" {
  name     = lower(var.rg)
  location = "eastus"
}
# terraform function format function
resource "azurerm_storage_account" "st" {
  name                     = lower(format("Storage%s%s", "BANK", var.stg-env)) ## storagebankdev
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
#terraform replace() function 
#replace(string, substring, replacement)
resource "azurerm_resource_group" "rg1" {
  name     = lower(replace(var.rg1, " ", "-"))
  location = "eastus"
}
#example2:
resource "azurerm_storage_account" "stg2" {
  name                     = lower(replace(format("Stg acc%s%s", "finance", var.stg-env), " ", "pr")) ## Stgpraccfinancedev
  resource_group_name      = azurerm_resource_group.rg1.name
  location                 = azurerm_resource_group.rg1.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "rg-creations" {
  source = "./modules/rg"
  testing-rg = {
    name     = var.testing-rg.name
    location = var.testing-rg.location
  }
}