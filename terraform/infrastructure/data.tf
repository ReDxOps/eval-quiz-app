data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg_projet_containers" {
  name = var.resource_group_name
}
