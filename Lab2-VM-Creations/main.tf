# data block to read vNet and subnet
data "azurerm_resource_group" "rg-name" {
  name = "vnet-rg"
}
data "azurerm_virtual_network" "vnet-test" {
  name                = "vnet1"
  resource_group_name = data.azurerm_resource_group.rg-name.name
}
data "azurerm_subnet" "subnet" {
  name                 = "subnet-a"
  resource_group_name  = data.azurerm_resource_group.rg-name.name
  virtual_network_name = data.azurerm_virtual_network.vnet-test.name
}
# create a VM
resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  resource_group_name = data.azurerm_resource_group.rg-name.name
  location            = data.azurerm_resource_group.rg-name.location
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.subnet.id
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}
# Public IP to take Remote of our deployed VM
resource "azurerm_public_ip" "pip" {
  name                = "vm-pip"
  resource_group_name = data.azurerm_resource_group.rg-name.name
  location            = data.azurerm_resource_group.rg-name.location
  allocation_method   = "Static"
  sku = ""
}
# NSG to allow RDP access to our VM
resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  resource_group_name = data.azurerm_resource_group.rg-name.name
  location            = data.azurerm_resource_group.rg-name.location
}
resource "azurerm_network_security_rule" "nsg-rule-rdp" {
  name                        = "Allow-RDP"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  resource_group_name         = data.azurerm_resource_group.rg-name.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
# associate NSG to NIC level
resource "azurerm_network_interface_security_group_association" "nsg-association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
# Windows VM creation
resource "azurerm_windows_virtual_machine" "windows-vm" {
  name                  = "windows-vm"
  resource_group_name   = data.azurerm_resource_group.rg-name.name
  location              = data.azurerm_resource_group.rg-name.location
  size                  = "Standard_D2s_v3"
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username        = "azureuser"
  admin_password        = "Welome@12345"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"

  }
}
output "vm_public_ip" {
  value = azurerm_public_ip.pip.ip_address
}