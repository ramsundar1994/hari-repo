resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}
resource "azurerm_virtual_network" "vnet" {
  name                = "example-vnet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/24"]
}
resource "azurerm_subnet" "subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}
## Create multiple NIC using Count meta data
resource "azurerm_network_interface" "nic" {
  count               = 2                    ## Create 2 NICs 0,1 [count.index] = 0, 1
  name                = "nic-${count.index}" ## Name of NIC will be nic-0, nic-1
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }
}
## create multiple Public IPs using count meta data
resource "azurerm_public_ip" "publicip" {
  count               = 2                         ## Create 2 Public IPs 0,1 [count.index] = 0, 1
  name                = "publicip-${count.index}" ## Name of Public IP will be publicip-0, publicip-1
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
}
## vm create using count meta data
resource "azurerm_windows_virtual_machine" "vm" {
  count               = 2                   ## Create 2 VMs 0,1 [count.index] = 0, 1
  name                = "vm-${count.index}" ## Name of VM will be vm-0, vm-1
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Password1234!"
  ##source_image_id = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/multiplevm-rg/providers/Microsoft.Compute/images/mycustomimage"
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
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
resource "null_resource" "null" {
  count = 2
  provisioner "local-exec" {
    command = "echo ${azurerm_public_ip.publicip[count.index].ip_address} >> ipaddress.txt"
  }
}