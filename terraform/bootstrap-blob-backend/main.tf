# Enregistrement des providers gérés par Terraform
resource "azurerm_resource_provider_registration" "providers" {
  for_each = toset([
    "Microsoft.Storage",
    "Microsoft.Compute",
    "Microsoft.Network",
    "Microsoft.ContainerService",
    "Microsoft.ContainerRegistry"
  ])

  name = each.key
}

resource "azurerm_resource_group" "rg_projet_containers" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_storage_account" "tfstate_storage_account" {
  name                     = var.tfstate_storage_account_name
  resource_group_name      = azurerm_resource_group.rg_projet_containers.name
  location                 = azurerm_resource_group.rg_projet_containers.location
  account_tier             = var.tfstate_storage_account_tier
  account_replication_type = var.tfstate_storage_account_replication_type

  blob_properties {
    versioning_enabled = true
  }

  depends_on = [azurerm_resource_provider_registration.providers]
}

resource "azurerm_storage_container" "tfstate_storage_container" {
  name                  = var.tfstate_storage_container
  storage_account_id    = azurerm_storage_account.tfstate_storage_account.id
  container_access_type = var.tfstate_storage_container_access_type
}