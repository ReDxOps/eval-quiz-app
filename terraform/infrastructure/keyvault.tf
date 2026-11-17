resource "azurerm_key_vault" "key_vault_projet_containers" {
  name                        = var.key_vault_projet_containers_name
  location                    = data.azurerm_resource_group.rg_projet_containers.location
  resource_group_name         = data.azurerm_resource_group.rg_projet_containers.name
  rbac_authorization_enabled  = var.key_vault_rbac_authorization_enabled
  enabled_for_disk_encryption = var.key_vault_enabled_for_disk_encryption
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.key_vault_soft_delete_retention_days
  purge_protection_enabled    = var.key_vault_purge_protection_enabled

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}
