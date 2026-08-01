#step1: RG Creation
resource "azurerm_resource_group" "rg-01" {
  name     = "appgateway-RG"
  location = "eastus"
}
#step 2" vNet creation
resource "azurerm_virtual_network" "vNet-01" {
  name                = "appgateway-vNet"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  address_space       = ["10.0.0.0/24"]
}
#step 3: Subnet creation for vm and application gateway
resource "azurerm_subnet" "subnet-vm" {
  name                 = "vm-subnet"
  address_prefixes     = ["10.0.0.0/26"]
  resource_group_name  = azurerm_resource_group.rg-01.name
  virtual_network_name = azurerm_virtual_network.vNet-01.name
}
resource "azurerm_subnet" "appgtw-subnet" {
  name                 = "appgateway-subnet"
  address_prefixes     = ["10.0.0.64/26"]
  resource_group_name  = azurerm_resource_group.rg-01.name
  virtual_network_name = azurerm_virtual_network.vNet-01.name
}
#step 4: virtual machine NIC Create
resource "azurerm_network_interface" "vm-nic" {
  name                = "vm-nic"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet-vm.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Step 5: Create windows VM
resource "azurerm_windows_virtual_machine" "windows-vm" {
  name                  = "appgateway-vm"
  resource_group_name   = azurerm_resource_group.rg-01.name
  location              = azurerm_resource_group.rg-01.location
  size                  = "Standard_B1s"
  admin_username        = "vmadmin"
  admin_password        = "Welcome@123"
  network_interface_ids = [azurerm_network_interface.vm-nic.id]
  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}
#Step 6 : install IIS using vm extension
resource "azurerm_virtual_machine_extension" "vm-ext" {
  name                 = "IIS"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings             = <<SETTINGS
{
  "commandToExecute": "powershell Install-WindowsFeature -name Web-Server -IncludeManagementTools"
}
SETTINGS
}
## Step 7: Create Public IP for Application Gateway as Front end
resource "azurerm_public_ip" "appgtw-pip" {
  name                = "appgateway-pip"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
# Step 8: Create Application Gateway
resource "azurerm_application_gateway" "appgtw" {
  name                = "appgateway-01"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "appgateway-ipconfig"
    subnet_id = azurerm_subnet.appgtw-subnet.id
  }
  frontend_port {
    name = "frontend-port"
    port = 80
  }
  frontend_ip_configuration {
    name                 = "appgateway-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgtw-pip.id
  }
  backend_address_pool {
    name         = "appgateway-backend-pool"
    ip_addresses = [azurerm_network_interface.vm-nic.private_ip_address]
  }
  http_listener {
    name                           = "appgateway-listener"
    frontend_ip_configuration_name = "appgateway-frontend-ip"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }
  backend_http_settings {
    name                  = "appgateway-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }
  request_routing_rule {
    name                       = "appgateway-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "appgateway-listener"
    backend_address_pool_name  = "appgateway-backend-pool"
    backend_http_settings_name = "appgateway-backend-http-settings"
    priority                   = 100
  }

}