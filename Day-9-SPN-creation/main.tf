
data "azurerm_subscription" "sub" {}

##app registeration
resource "azuread_application" "app" {
  display_name = "hari-app-spn"
}

## app secret
resource "azuread_application_password" "appsecret" {
  display_name   = "hari-app-secret"
  application_id = azuread_application.app.id
}
## service principal
resource "azuread_service_principal" "spn" {
  client_id = azuread_application.app.client_id
}
## SPN secrets
resource "azuread_service_principal_password" "spnsecret" {
  service_principal_id = azuread_service_principal.spn.id
  display_name         = "spn-secret"
}
## Role Assignment
resource "azurerm_role_assignment" "spnrole" {
  scope                = data.azurerm_subscription.sub.id
  principal_id         = azuread_service_principal.spn.object_id
  role_definition_name = "Contributor"
}
output "spn_secret" {
  value     = azuread_service_principal_password.spnsecret.value
  sensitive = true
}