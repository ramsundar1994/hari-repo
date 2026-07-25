locals {
  vm_metadata = {
    "app1" = {
      size     = "Standard_B1ms"
      username = "vmadmin"
    }
    "app2" = {
      size     = "Standard_D2s_v3"
      username = "azureuser"
    }
  }
}