resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-function"
  location = "eastus"

}
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"] ##65536 IPs
}
## map + key + forach
resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}
## For expression
resource "azurerm_subnet" "subnet2" {
    for_each = {
        for idx, sub in var.sub : idx => sub
    }
    name = "subnet-${each.key}"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [each.value]
}