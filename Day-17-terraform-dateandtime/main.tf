locals {
  current_time = timestamp() ## "2026-07-11T09:19:05Z"
  current_date = formatdate("YYYY-MM-DD", local.current_time)  ##2026-07-11
}
output "current_time" {
  value = local.current_time
}
output "current_date" {
  value = local.current_date
}
resource "azurerm_resource_group" "date" {
    name = "testing"
    location = "East US"
    tags = {
        resource_created_date = local.current_date
        resource_created_time = local.current_time
    }
}