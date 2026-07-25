resource "azurerm_resource_group" "rg" {
  name     = "foreach-rg"
  location = "eastus"
}
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/24"]
}
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-a"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.0.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
}
## public IP 
resource "azurerm_public_ip" "pip" {
  for_each            = local.vm_metadata
  name                = "pip-${each.key}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

## multiple NICs
resource "azurerm_network_interface" "nic" {
  for_each            = local.vm_metadata
  name                = "vm-nic-${each.key}" ## vm-nic-app1
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "ipconfig-${each.key}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}
## multiple vms creation
resource "azurerm_linux_virtual_machine" "linux" {
  for_each              = local.vm_metadata
  name                  = "vm-linux-${each.key}" #vm-linux-app1
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = each.value.size
  admin_username        = each.value.username
  admin_password        = "Password@12345"
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  custom_data           = base64encode(file("cloud-init.yaml"))
  os_disk {
    name                 = "os-disk-linux-${each.key}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  disable_password_authentication = false
}
resource "azurerm_network_security_group" "nsg-01" {
  name                = "vm-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}
resource "azurerm_network_security_rule" "nsg-rule" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg-01.name
  resource_group_name         = azurerm_resource_group.rg.name
}
resource "azurerm_network_security_rule" "rule2" {
  name                        = "AllowHTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg-01.name
}
# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nsg-associate" {
  for_each                  = local.vm_metadata
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg-01.id
}
