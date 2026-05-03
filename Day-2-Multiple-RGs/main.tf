# Multiple RG's
resource "azurerm_resource_group" "rg-name" {
  name     = "first-rg"
  location = "eastus"
}
resource "azurerm_resource_group" "rg-name2" {
  name     = "second-rg"
  location = "westus"
}
resource "azurerm_resource_group" "rg-name3" {
  name     = "third-rg"
  location = "eastus"

}