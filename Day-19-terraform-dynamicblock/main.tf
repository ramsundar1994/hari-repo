resource "azurerm_resource_group" "rg" {
  name     = "dynamic-rg"
  location = "eastus"
}
resource "azurerm_virtual_network" "vnet" {
  name                = "dynamic-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/22"] ## 1024 IPAddress
  dynamic "subnet" {
    for_each = var.subnet
    content {
      name             = subnet.value.name
      address_prefixes = subnet.value.address_prefix
    }
  }
}
## multiple NIC cards based on dynamics subnets ## key value pair 
resource "azurerm_network_interface" "nic" {
  for_each = {
    for subnet in azurerm_virtual_network.vnet.subnet : subnet.name => subnet ##subnet-a = 10.0.1.0/24 subnet-b =10.0.0.0/24
  }
  name                = "nic-${each.key}-01" ## nic-subnet-a-01 , nic-subnet-b-01
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.id
    private_ip_address_allocation = "Dynamic"
  }
}
## Network security group
resource "azurerm_network_security_group" "nsg" {
  name                = "dynamic-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dynamic "security_rule" {
    for_each = var.nsg
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      destination_port_range     = security_rule.value.destination_port_range
    }
  }
}
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  for_each                  = azurerm_network_interface.nic
  network_interface_id      = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "windows-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  admin_password        = "P@ssword1234!"
  network_interface_ids = [for nic in azurerm_network_interface.nic : nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}