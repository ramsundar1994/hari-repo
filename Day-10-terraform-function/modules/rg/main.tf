resource "azurerm_resource_group" "rg-test" {
  name = lower(replace(var.testing-rg.name," ","-"))
  location = lower(var.testing-rg.location)
}