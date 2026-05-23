rg-details = {
  name     = "vm-rg"
  location = "eastus"
}
vnet-details = {
  name          = "vm-vnet-01"
  address_space = ["10.0.0.0/24", "10.0.1.0/24"]
}
subnet-details = {
  name             = "vm-subnet-01"
  address_prefixes = ["10.0.0.0/24", "10.0.1.0/24"]
}
nics = ["nic-01", "nic-02"]
vm_details = {
  name           = "windows-vm-01"
  size           = "Standard_D2s_v3"
  admin_username = "azureuser"
  admin_password = "Welcome@12345"
  publisher      = "MicrosoftWindowsServer"
  offer          = "WindowsServer"
  sku            = "2022-datacenter"
  version        = "latest"
}
tags = {
  "env"        = "testing"
  "dept"       = "IT"
  "project"    = "vmcreation"
  "owner"      = "hari"
  "costcenter" = "1001"
}