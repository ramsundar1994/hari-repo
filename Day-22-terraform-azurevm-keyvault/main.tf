data "azurerm_client_config" "current" {
  # tenant id
  # subscription id
  # object id
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-azurevm-keyvault"
  location = "East US"
}
## random password generation
resource "random_password" "password" {
  length           = 16 ## HJHKNKYGI@$^
  special          = true
  override_special = "_%@#"
}
##keyvault creation
resource "azurerm_key_vault" "keyvault" {
  name                       = "kv-test-np01"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
}
## keyvault secret creation
resource "azurerm_key_vault_secret" "secret" {
  depends_on   = [random_password.password]
  name         = "vm-password"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.keyvault.id
}
resource "azurerm_role_assignment" "keyvault_role_assignment" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_client_config.current.object_id
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
##NIC Creation
resource "azurerm_network_interface" "nic" {
  name                = "nic-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "ipconfig"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.5"
    subnet_id                     = azurerm_subnet.subnet.id
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}
##PIP Creation
resource "azurerm_public_ip" "pip" {
  name                = "pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  allocation_method   = "Static"
}
## VM Creation
resource "azurerm_linux_virtual_machine" "vm" {
  depends_on            = [azurerm_key_vault_secret.secret]
  name                  = "vm-01"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  admin_password        = azurerm_key_vault_secret.secret.value
  os_disk {
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
#NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}
resource "azurerm_network_security_rule" "nsg-rule" {
  name                        = "Allow-RDP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name

}
resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}