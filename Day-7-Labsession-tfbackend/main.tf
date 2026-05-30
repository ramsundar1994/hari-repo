terraform {
backend "azurerm" {
  resource_group_name   = "Devops-RG"
  storage_account_name  = "storage1419413"
  container_name        = "terraform-statefile"
  key                   = "dev-terraform.tfstate"
}
}
resource "azurerm_resource_group" "rg" {
  name     = "rg-tf-backend"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  depends_on = [azurerm_resource_group.rg]
  name = "vnet-test"
  resource_group_name =  azurerm_resource_group.rg.name
  location =  azurerm_resource_group.rg.location
  address_space = ["10.0.0.0/24"]
}
##Implicit dependency on resource group and virtual network
resource "azurerm_subnet" "subnet" {
  name = "subnet-test"
  resource_group_name =  azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.0.0/24"]
}
## Explicit dependency on resource group and virtual network
resource "azurerm_network_interface" "nic" {
  depends_on = [azurerm_virtual_network.vnet, azurerm_resource_group.rg]
  name = "nic-test"
  resource_group_name =  azurerm_resource_group.rg.name
  location =  azurerm_resource_group.rg.location
  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}