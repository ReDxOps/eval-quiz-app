output "github_actions_client_id" {
  description = "Valeur pour le secret GitHub AZURE_CLIENT_ID"
  value       = azurerm_user_assigned_identity.github_actions.client_id
}

output "azure_tenant_id" {
  description = "Valeur pour le secret GitHub AZURE_TENANT_ID"
  value       = data.azurerm_client_config.current.tenant_id
}

output "azure_subscription_id" {
  description = "Valeur pour le secret GitHub AZURE_SUBSCRIPTION_ID"
  value       = data.azurerm_client_config.current.subscription_id
}
