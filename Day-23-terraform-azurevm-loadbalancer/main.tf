#resource group
resource "azurerm_resource_group" "rg-01" {
  name     = "load-balancer-rg"
  location = "eastus"
}
#vNet creations
resource "azurerm_virtual_network" "vnet1" {
  name                = "lb-vnet-001"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  address_space       = ["10.0.0.0/24"]
}
#subnet creation
resource "azurerm_subnet" "subnet" {
  name                 = "lb-subnet"
  resource_group_name  = azurerm_resource_group.rg-01.name
  address_prefixes     = ["10.0.0.0/28"]
  virtual_network_name = azurerm_virtual_network.vnet1.name
}
##Step 1
## Public IP for LB
resource "azurerm_public_ip" "lb-pip" {
  name                = "lb-public-ip"
  location            = azurerm_resource_group.rg-01.location
  resource_group_name = azurerm_resource_group.rg-01.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
##Step 2
## External load balancer 
resource "azurerm_lb" "lb" {
  name                = "azure-lb"
  location            = azurerm_resource_group.rg-01.location
  resource_group_name = azurerm_resource_group.rg-01.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "lb-frontend-ip"
    public_ip_address_id = azurerm_public_ip.lb-pip.id
  }
}
##Step 3
## Backend pool for load balancer
resource "azurerm_lb_backend_address_pool" "backend-pool" {
  name            = "lb-backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}
##Step 4
## Health probe for load balancer
resource "azurerm_lb_probe" "lb-probe" {
  name            = "lb-health-probe"
  loadbalancer_id = azurerm_lb.lb.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}
###Step 5
## Load balancer rule
resource "azurerm_lb_rule" "lb-rule" {
  name                           = "lb-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = "lb-frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend-pool.id]
  probe_id                       = azurerm_lb_probe.lb-probe.id
  frontend_port                  = 80
  backend_port                   = 80
  protocol                       = "Tcp"
}
##Step 6
## VM NIC
resource "azurerm_network_interface" "nic1" {
  name                = "vm1-nic"
  location            = azurerm_resource_group.rg-01.location
  resource_group_name = azurerm_resource_group.rg-01.name
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
## Step 7
## Associate VM Nic with Backendpool
resource "azurerm_network_interface_backend_address_pool_association" "nic1-association" {
  network_interface_id    = azurerm_network_interface.nic1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend-pool.id
}
### Step 8 creaet NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg-01"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
}
resource "azurerm_network_security_rule" "nsg-rule" {
  name                        = "Allow-http"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg-01.name
}
resource "azurerm_network_security_rule" "nsg-rule-rdp" {
  name                        = "Allow-rdp"
  priority                    = 112
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg-01.name
}
## Step 9
## Associate NSG with VM NIC
resource "azurerm_network_interface_security_group_association" "nic1-nsg-association" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
## Step 10
## VM Creations
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "vm1"
  resource_group_name   = azurerm_resource_group.rg-01.name
  location              = azurerm_resource_group.rg-01.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  admin_password        = "Admin@12345"
  network_interface_ids = [azurerm_network_interface.nic1.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}
## Step 11
#VM Extension for enabling IIS server on the VM
resource "azurerm_virtual_machine_extension" "vm-extension" {
  name                 = "IIS"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings             = <<SETTINGS
{
  "commandToExecute": "powershell Install-WindowsFeature -name Web-Server -IncludeManagementTools"
}
SETTINGS
}
## Step 12
##NAT rule for RDP
resource "azurerm_lb_nat_rule" "lb-nat-rule" {
  name                           = "lb-nat-rule"
  resource_group_name            = azurerm_resource_group.rg-01.name
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = "lb-frontend-ip"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
}
### Step 13
## Associate NAT rule with VM NIC
resource "azurerm_network_interface_nat_rule_association" "nic1-nat-association" {
  network_interface_id  = azurerm_network_interface.nic1.id
  ip_configuration_name = "ipconfig1"
  nat_rule_id           = azurerm_lb_nat_rule.lb-nat-rule.id
}