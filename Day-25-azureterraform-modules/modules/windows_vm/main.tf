## NIC Creations
resource "azurerm_network_interface" "nic" {
  count = var.nic_count 
  name                = "${var.vm_name}-nic-${count.index}" ## windows-vm-nic-0 , windows-vm-nic-1
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig-${count.index}" ## ipconfig-0 , ipconfig-1
    subnet_id                     =  var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

## Windows VM
resource "azurerm_windows_virtual_machine" "vm" {
    name = var.vm_name
    location = var.location
    resource_group_name = var.resource_group_name
    size = var.vm_size
    admin_username = var.admin_username
    admin_password = var.admin_password
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    network_interface_ids = azurerm_network_interface.nic[*].id
    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = var.image_sku
        version   = "latest"
    }
}