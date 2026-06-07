#collection function list+length+count
resource "azurerm_resource_group" "rg" {
  count = length(var.rg-details) # count = [0,1,2]
  name = var.rg-details[count.index] # var.rg-details[0], var.rg-details[1], var.rg-details[2]
  location = "eastus"
}
resource "azurerm_virtual_network" "vnet" {
    name = "hari-vnet-01"
    resource_group_name = azurerm_resource_group.rg[1].name
    location = azurerm_resource_group.rg[1].location
    address_space = ["10.0.0.0/24"]
}
resource "azurerm_virtual_network" "vnet_01" {
    name = "hari-vnet-02"
    resource_group_name = azurerm_resource_group.rg[2].name
    location = azurerm_resource_group.rg[2].location
    address_space = ["10.0.1.0/24"]
}                