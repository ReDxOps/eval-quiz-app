resource "random_password" "pg_admin" {
  length  = 24
  special = false
}

resource "azurerm_postgresql_flexible_server" "pg" {
  name                   = var.pg_server_name
  resource_group_name    = data.azurerm_resource_group.rg_projet_containers.name
  location               = data.azurerm_resource_group.rg_projet_containers.location
  version                = var.pg_version
  administrator_login    = var.pg_admin_login
  administrator_password = random_password.pg_admin.result
  sku_name               = var.pg_sku_name
  storage_mb             = var.pg_storage_mb
  backup_retention_days  = 7

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "quiz_db" {
  name      = var.pg_db_name
  server_id = azurerm_postgresql_flexible_server.pg.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "AllowAllAzureServices"
  server_id        = azurerm_postgresql_flexible_server.pg.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_key_vault_secret" "database_url" {
  name         = "database-url"
  value        = "postgres://${var.pg_admin_login}:${random_password.pg_admin.result}@${azurerm_postgresql_flexible_server.pg.fqdn}:5432/${var.pg_db_name}?sslmode=require"
  key_vault_id = azurerm_key_vault.key_vault_projet_containers.id
}

resource "terraform_data" "init_db" {
  triggers_replace = [azurerm_postgresql_flexible_server_database.quiz_db.id]

  provisioner "local-exec" {
    interpreter = ["bash", "-euo", "pipefail", "-c"]
    environment = {
      DATABASE_URL = azurerm_key_vault_secret.database_url.value
    }

    command = <<-EOT
      MY_IP=$(curl -s https://ifconfig.me)
      cleanup() {
        az postgres flexible-server firewall-rule delete \
          -g "${data.azurerm_resource_group.rg_projet_containers.name}" \
          -n "${azurerm_postgresql_flexible_server.pg.name}" \
          --rule-name temp-tf-init --yes >/dev/null 2>&1 || true
      }
      trap cleanup EXIT

      az postgres flexible-server firewall-rule create \
        -g "${data.azurerm_resource_group.rg_projet_containers.name}" \
        -n "${azurerm_postgresql_flexible_server.pg.name}" \
        --rule-name temp-tf-init \
        --start-ip-address "$MY_IP" \
        --end-ip-address "$MY_IP" >/dev/null

      if command -v psql >/dev/null 2>&1; then
        psql "$DATABASE_URL" -f "${path.module}/../../database/init.sql"
      else
        docker run --rm -i postgres:18-alpine psql "$DATABASE_URL" < "${path.module}/../../database/init.sql"
      fi
    EOT
  }

  depends_on = [azurerm_postgresql_flexible_server_database.quiz_db]
}
