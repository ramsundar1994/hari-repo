# Resource group
resource "azurerm_resource_group" "rg-name" {
  name = "Development-RG"
  location = "eastus"
}
resource "azurerm_resource_group" "rg-dev" {
  name = "Testing-RG"
  location = "westus"
}