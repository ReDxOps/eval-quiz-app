resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.rg_projet_containers.name
  location            = data.azurerm_resource_group.rg_projet_containers.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_user_assigned_identity" "aca_identity" {
  name                = var.aca_identity_name
  resource_group_name = data.azurerm_resource_group.rg_projet_containers.name
  location            = data.azurerm_resource_group.rg_projet_containers.location
}

resource "azurerm_role_assignment" "containers_app_pull" {
  principal_id                     = azurerm_user_assigned_identity.aca_identity.principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

