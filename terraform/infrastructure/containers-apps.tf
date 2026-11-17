resource "azurerm_log_analytics_workspace" "aca_logs" {
  name                = var.log_analytics_workspace_name
  location            = data.azurerm_resource_group.rg_projet_containers.location
  resource_group_name = data.azurerm_resource_group.rg_projet_containers.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "aca_env" {
  name                       = var.aca_environment_name
  location                   = data.azurerm_resource_group.rg_projet_containers.location
  resource_group_name        = data.azurerm_resource_group.rg_projet_containers.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca_logs.id
}

resource "azurerm_container_app" "backend" {
  name                         = var.aca_backend_name
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = data.azurerm_resource_group.rg_projet_containers.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  ingress {
    external_enabled = false
    target_port      = var.aca_backend_port
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = var.aca_min_replicas
    max_replicas = var.aca_max_replicas

    container {
      name   = "backend"
      image  = "${azurerm_container_registry.acr.login_server}/${var.aca_backend_image}"
      cpu    = var.aca_cpu
      memory = var.aca_memory
    }
  }

  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }

  depends_on = [azurerm_role_assignment.containers_app_pull]
}

resource "azurerm_container_app" "frontend" {
  name                         = var.aca_frontend_name
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = data.azurerm_resource_group.rg_projet_containers.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  ingress {
    external_enabled = true
    target_port      = var.aca_frontend_port
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = var.aca_min_replicas
    max_replicas = var.aca_max_replicas

    container {
      name   = "frontend"
      image  = "${azurerm_container_registry.acr.login_server}/${var.aca_frontend_image}"
      cpu    = var.aca_cpu
      memory = var.aca_memory
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
