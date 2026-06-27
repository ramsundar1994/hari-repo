##conditional expression
## condition ? true_value : false_value  1:0 
resource "azurerm_resource_group" "rg" {
  count    = var.env == "prod" ? 1 : 0
  name     = "prod-rg"
  location = "eastus"
}
resource "azurerm_resource_group" "rg1" {
  count    = var.env == "nonprod" ? 1 : 0
  name     = "nonprod-rg"
  location = "eastus"
}
locals {
  storage_type = var.env == "nonprod" ? "GRS" : "LRS"
}
output "stg" {
  value = local.storage_type
}