resource "azurerm_resource_group" "rg1" {
  name     = var.rg-details.name
  location = var.rg-details.location
  tags     = var.tags
}
resource "azurerm_virtual_network" "vnet1" {
  name                = var.vnet-details.name
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  address_space       = [var.vnet-details.address_space[0]]
  tags                = var.tags
}
resource "azurerm_subnet" "subnets" {
  name                 = var.subnet-details.name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = [var.subnet-details.address_prefixes[0]]
}
resource "azurerm_network_interface" "nic" {
  for_each            = toset(var.nics)
  name                = each.value
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  ip_configuration {
    name                          = "${each.value}-ipconfig1"
    subnet_id                     = azurerm_subnet.subnets.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                  = var.vm_details.name
  resource_group_name   = azurerm_resource_group.rg1.name
  location              = azurerm_resource_group.rg1.location
  size                  = var.vm_details.size
  admin_username        = var.vm_details.admin_username
  admin_password        = var.vm_details.admin_password
  network_interface_ids = [for nics in azurerm_network_interface.nic : nics.id]
  os_disk {
    name                 = "windowsosdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = var.vm_details.publisher
    offer     = var.vm_details.offer
    sku       = var.vm_details.sku
    version   = var.vm_details.version
  }
  tags = var.tags
}