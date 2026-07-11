##rg creation
resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-provisioner"
  location = "East US"
}
## virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-terraform-provisioner"
  address_space       = ["10.0.0.0/24"]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}
## subnet creation
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-terraform"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}
### public ip creation
resource "azurerm_public_ip" "publicip" {
  name                = "publicip-terraform"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
## network interface creation
resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}
## virtual machine creation
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "windows-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_D2s_v3"
  admin_username        = "adminuser"
  admin_password        = "Welcome@12345"
  network_interface_ids = [azurerm_network_interface.nic.id]
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

  ##local provisioner
  provisioner "local-exec" {
    command = "echo VM Created with public IP ${azurerm_public_ip.publicip.ip_address} >> vm_info.txt"
  }
}
resource "azurerm_virtual_machine_extension" "vm_extension" {
  name                 = "Enable-winrm" ## WINRM Service port 5985 or 5986
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  type                 = "CustomScriptExtension"
  publisher            = "Microsoft.Compute"
  type_handler_version = "1.10"
  settings             = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"Enable-PSRemoting -Force; winrm quickconfig -force; Set-Item -Path WSMan:\\localhost\\Service\\AllowUnencrypted -Value true; Set-Item -Path WSMan:\\localhost\\Service\\Auth\\Basic -Value true; netsh advfirewall firewall add rule name=\\\"WinRM-HTTP\\\" dir=in action=allow protocol=TCP localport=5985; Restart-Service WinRM\"" 
  }
  SETTINGS

}
resource "null_resource" "copy_script" {
  depends_on = [azurerm_virtual_machine_extension.vm_extension, azurerm_windows_virtual_machine.vm] ## to ensure winrm is enabled before copying the script
  provisioner "file" {
    source      = "install.ps1"
    destination = "C:/install.ps1"
    connection {
      type     = "winrm"
      host     = azurerm_public_ip.publicip.ip_address
      user     = azurerm_windows_virtual_machine.vm.admin_username
      password = azurerm_windows_virtual_machine.vm.admin_password
      port     = 5985 ## HTTP port for WinRM
      https    = false
      insecure = true
    }
  } ### after copy file remote exec will execute the script
  provisioner "remote-exec" {
    inline = [
      "powershell.exe -ExecutionPolicy Unrestricted -File C:/install.ps1",
      "powershell.exe echo 'Script executed successfully!' >> C:/output.txt"
    ]
    connection {
      type     = "winrm"
      host     = azurerm_public_ip.publicip.ip_address
      user     = azurerm_windows_virtual_machine.vm.admin_username
      password = azurerm_windows_virtual_machine.vm.admin_password
      port     = 5985 ## HTTP port for WinRM
      https    = false
      insecure = true
    }
  }
}
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-terraform"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_network_security_rule" "nsg-rule1" {
  name                        = "Allow-RDP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
resource "azurerm_network_security_rule" "nsg-rule2" {
  name                        = "Allow-winrm"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5985" #http #https:5986
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
resource "azurerm_network_interface_security_group_association" "nsg-association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
