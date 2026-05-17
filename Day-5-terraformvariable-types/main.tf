#example 1 : Terraform variable types : String
resource "azurerm_resource_group" "rg1" {
  name     = var.rg-name
  location = var.loc
}

#example 2 : Terraform variable types : List --> For each loop

resource "azurerm_resource_group" "rg2" {
  for_each = toset(var.rg-names)
  name     = each.value
  location = var.loc
}

#example 3 : Terraform variable types : list --> count loop

resource "azurerm_resource_group" "rg3" {
  count    = length(var.locations)
  name     = "terraform-${var.locations[count.index]}-${var.env}-RG"
  location = var.locations[count.index]
}

#example 4 : Terraform variable types : map --> for each loop

resource "azurerm_resource_group" "rg4" {
    for_each = var.rg-details
    name = each.key
    location = each.value
}