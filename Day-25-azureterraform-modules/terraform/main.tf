## RG Creation using modules
module "rg" {
  source              = "../modules/resource-group"
  resource_group_name = "rg-terraform-modules"
  location            = "East US"
}
## Network creation using network modules
module "network" {
  source              = "../modules/networks"
  vnet_name           = "vnet-test01"
  address_space       = ["10.0.0.0/22"]
  location            = module.rg.rg-location
  resource_group_name = module.rg.rg-name
}
## subnet creations
module "subnet1" {
  source               = "../modules/subnets"
  subnet_name          = "subnet-test01"
  address_prefixes     = ["10.0.0.0/24"]
  resource_group_name  = module.rg.rg-name
  virtual_network_name = module.network.vnet_name
}
## VM Creations
module "windows_vm" {
  source              = "../modules/windows_vm"
  for_each            = var.vm_config
  vm_name             = each.key
  vm_size             = each.value.vm_size
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
  nic_count           = each.value.nic_count
  resource_group_name = module.rg.rg-name
  location            = module.rg.rg-location
  image_sku           = each.value.image_sku
  subnet_id           = module.subnet1.subnet_id

}