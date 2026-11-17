resource "azurerm_log_analytics_workspace" "aca_logs" {
  name                = var.log_analytics_workspace_name
  location            = data.azurerm_resource_group.rg_projet_containers.location
  resource_group_name = data.azurerm_resource_group.rg_projet_containers.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days
}

resource "azurerm_container_app_environment" "aca_env" {
  name                       = var.aca_environment_name
  location                   = data.azurerm_resource_group.rg_projet_containers.location
  resource_group_name        = data.azurerm_resource_group.rg_projet_containers.name
  logs_destination           = var.aca_logs_destination
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca_logs.id
}

data "azurerm_key_vault_secret" "jwt_secret" {
  name         = "jwt-secret"
  key_vault_id = azurerm_key_vault.key_vault_projet_containers.id
}

data "azurerm_key_vault_secret" "admin_username" {
  name         = "admin-username"
  key_vault_id = azurerm_key_vault.key_vault_projet_containers.id
}

data "azurerm_key_vault_secret" "admin_password" {
  name         = "admin-password"
  key_vault_id = azurerm_key_vault.key_vault_projet_containers.id
}

data "azurerm_key_vault_secret" "resend_api_key" {
  name         = "resend-api-key"
  key_vault_id = azurerm_key_vault.key_vault_projet_containers.id
}

data "azurerm_key_vault_secret" "from_email" {
  name         = "from-email"
  key_vault_id = azurerm_key_vault.key_vault_projet_containers.id
}

resource "azurerm_container_app" "backend" {
  name                         = var.aca_backend_name
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = data.azurerm_resource_group.rg_projet_containers.name
  revision_mode                = var.aca_revision_mode

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  secret {
    name  = "database-url"
    value = azurerm_key_vault_secret.database_url.value
  }

  secret {
    name  = "jwt-secret"
    value = data.azurerm_key_vault_secret.jwt_secret.value
  }

  secret {
    name  = "admin-username"
    value = data.azurerm_key_vault_secret.admin_username.value
  }

  secret {
    name  = "admin-password"
    value = data.azurerm_key_vault_secret.admin_password.value
  }

  secret {
    name  = "resend-api-key"
    value = data.azurerm_key_vault_secret.resend_api_key.value
  }

  secret {
    name  = "from-email"
    value = data.azurerm_key_vault_secret.from_email.value
  }

  ingress {
    external_enabled = var.aca_backend_external_enabled
    target_port      = var.aca_backend_port
    transport        = var.aca_ingress_transport

    traffic_weight {
      percentage      = var.aca_traffic_percentage
      latest_revision = true
    }
  }

  template {
    min_replicas = var.aca_min_replicas
    max_replicas = var.aca_max_replicas

    container {
      name   = var.aca_backend_container_name
      image  = "${azurerm_container_registry.acr.login_server}/${var.aca_backend_image}"
      cpu    = var.aca_cpu
      memory = var.aca_memory

      env {
        name        = "DATABASE_URL"
        secret_name = "database-url"
      }

      env {
        name        = "JWT_SECRET"
        secret_name = "jwt-secret"
      }

      env {
        name        = "ADMIN_USERNAME"
        secret_name = "admin-username"
      }

      env {
        name        = "ADMIN_PASSWORD"
        secret_name = "admin-password"
      }

      env {
        name        = "RESEND_API_KEY"
        secret_name = "resend-api-key"
      }

      env {
        name        = "FROM_EMAIL"
        secret_name = "from-email"
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }

  depends_on = [
    azurerm_role_assignment.containers_app_pull,
    azurerm_key_vault_secret.database_url,
  ]
}

resource "azurerm_container_app" "frontend" {
  name                         = var.aca_frontend_name
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = data.azurerm_resource_group.rg_projet_containers.name
  revision_mode                = var.aca_revision_mode

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  ingress {
    external_enabled = var.aca_frontend_external_enabled
    target_port      = var.aca_frontend_port
    transport        = var.aca_ingress_transport

    traffic_weight {
      percentage      = var.aca_traffic_percentage
      latest_revision = true
    }
  }

  template {
    min_replicas = var.aca_min_replicas
    max_replicas = var.aca_max_replicas

    container {
      name   = var.aca_frontend_container_name
      image  = "${azurerm_container_registry.acr.login_server}/${var.aca_frontend_image}"
      cpu    = var.aca_cpu
      memory = var.aca_memory

      env {
        name  = "BACKEND_URL"
        value = "https://${azurerm_container_app.backend.ingress[0].fqdn}"
      }

      env {
        name  = "BACKEND_HOST"
        value = azurerm_container_app.backend.ingress[0].fqdn
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }

  depends_on = [
    azurerm_role_assignment.containers_app_pull,
    azurerm_container_app.backend,
  ]
}
