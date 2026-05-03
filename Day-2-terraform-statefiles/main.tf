# Multiple RG's
resource "azurerm_resource_group" "rg-name" {
  name     = "first-rg"
  location = "eastus"
  tags = {
    "Name"  = "testing-rg"
    "owner" = "john"
  }
}
resource "azurerm_resource_group" "rg-name2" {
  name     = "second-rg"
  location = "westus"
  tags = {
    "Name"  = "testing-rg"
    "owner" = "john-doe"
  }
}

resource "azurerm_resource_group" "rg-name3" {
  name     = "third-rg"
  location = "eastus"
}
