data "azurerm_resource_group" "rg-name" {
  name = "production-rg"
}
resource "azurerm_managed_disk" "disk-name" {
  name                 = "production-disk"
  resource_group_name  = data.azurerm_resource_group.rg-name.name
  location             = data.azurerm_resource_group.rg-name.location
  storage_account_type = "Standard_LRS"
  disk_size_gb         = 10
  create_option        = "Empty"

}