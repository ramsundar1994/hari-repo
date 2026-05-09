# Resource Group for vNet 
resource "azurerm_resource_group" "rg-name" {
  name     = "vnet-rg"
  location = "eastus"
}
# Virtual Network Creation 
resource "azurerm_virtual_network" "vnet-name" {
  name                = "vnet1"
  resource_group_name = azurerm_resource_group.rg-name.name
  location            = azurerm_resource_group.rg-name.location
  address_space       = ["10.0.0.0/24"]
}
# Subnet Creation
resource "azurerm_subnet" "subnet-a" {
  name                 = "subnet-A"
  resource_group_name  = azurerm_resource_group.rg-name.name
  virtual_network_name = azurerm_virtual_network.vnet-name.name
  address_prefixes     = ["10.0.0.0/28"] # This subnet will have 16 IP addresses (14 usable for hosts, 1 for network, 1 for broadcast)
}
resource "azurerm_subnet" "subnet-b" {
  name                 = "subnet-B"
  resource_group_name  = azurerm_resource_group.rg-name.name
  virtual_network_name = azurerm_virtual_network.vnet-name.name
  address_prefixes     = ["10.0.0.16/28"] # Adjusted to avoid overlap with subnet-A 16IP addresses
}