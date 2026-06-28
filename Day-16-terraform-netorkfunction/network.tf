resource "azurerm_resource_group" "rg" {
  name     = "network-rg"
  location = "eastus"
}
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "subnets" {
  name                 = "subnet-01"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [
    cidrsubnet(tolist(azurerm_virtual_network.vnet.address_space)[0], 7, 0) ##512 IPs
  ]
  virtual_network_name = azurerm_virtual_network.vnet.name
}
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet-02"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [
    cidrsubnet(tolist(azurerm_virtual_network.vnet.address_space)[0], 7, 1)
  ]
  virtual_network_name = azurerm_virtual_network.vnet.name
}