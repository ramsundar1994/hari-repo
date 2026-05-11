# Input variables
#inline variable Example 1
variable "rg_name" {
  type        = string
  default     = "testing-rg"
  description = "Name of the resource group"
}
variable "loc" {
  type        = string
  default     = "eastus"
  description = "Azure region for the resource group"
}
resource "azurerm_resource_group" "rg-name" {
  name     = var.rg_name
  location = var.loc
}

#Example 2 for external variable
resource "azurerm_resource_group" "rg-ext" {
  name = var.rg_name2
  location = var.loc2
}
#Example 3 : local variables
locals {
  rg_name3 = "local-rg"
  loc3 = "centralus"
}
resource "azurerm_resource_group" "rg-local" {
  name = local.rg_name3
  location = local.loc3
}

resource "azurerm_resource_group" "rg-mixed" {
  name = local.resource_group
  location = local.location
}
# inline ouput variables
output "rg_name_output" {
  value = azurerm_resource_group.rg-local.id
}