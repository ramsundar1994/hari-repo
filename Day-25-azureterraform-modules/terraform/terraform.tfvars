vm_config = {
  "windowsvm-01" = {
    vm_size        = "Standard_B1s"
    admin_username = "adminuser"
    admin_password = "Admin@12345"
    nic_count      = 2
    image_sku      = "2019-Datacenter"
  }
  "windowsvm-02" = {
    vm_size        = "Standard_DS1_v2"
    admin_username = "windowsuser"
    admin_password = "Admin@12345"
    nic_count      = 1
    image_sku      = "2022-Datacenter"
  }
}