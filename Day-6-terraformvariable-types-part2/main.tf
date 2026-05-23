resource "azurerm_resource_group" "rgnames" {
  name = var.rg-details.name
  location = var.rg-details.location
}

resource "azurerm_resource_group" "rg1" {
  name = var.nested-rg["dev"].name
  location = var.nested-rg["dev"].location
  tags = var.nested-rg["dev"].tags
}
resource "azurerm_resource_group" "rg2" {
  name = var.nested-rg["prod"].name
  location = var.nested-rg["prod"].location
  tags = var.nested-rg["prod"].tags
}