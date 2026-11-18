variable "resource_group_name" {
  type    = string
  default = "rg_projet_containers"
}

variable "resource_group_location" {
  type    = string
  default = "switzerlandnorth"
}

variable "key_vault_projet_containers_name" {
  type    = string
  default = "kv-containers"
}

variable "key_vault_rbac_authorization_enabled" {
  type    = bool
  default = false
}

variable "key_vault_enabled_for_disk_encryption" {
  type    = bool
  default = true
}

variable "key_vault_soft_delete_retention_days" {
  type    = number
  default = 7
}

variable "key_vault_purge_protection_enabled" {
  type    = bool
  default = false
}

variable "acr_name" {
  type    = string
  default = "acrprojetcontainers34323"
}

variable "aca_identity_name" {
  type        = string
  description = "Nom de la User-Assigned Managed Identity pour Azure Container Apps (AcrPull)"
  default     = "id-aca-pull"
}

variable "github_actions_identity_name" {
  type        = string
  description = "Nom de la User-Assigned Managed Identity pour GitHub Actions"
  default     = "id-github-actions"
}

variable "github_repository" {
  type        = string
  description = "Dépôt GitHub au format owner/repo (avec IDs immuables OIDC)"
  default     = "ReDxOps@107931401/eval-quiz-app@1461208616"
}

variable "github_branch" {
  type        = string
  description = "Branche GitHub autorisée à s'authentifier via OIDC"
  default     = "main"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Nom du Log Analytics Workspace pour Azure Container Apps"
  default     = "law-eval-quiz"
}

variable "aca_environment_name" {
  type        = string
  description = "Nom de l'environnement Azure Container Apps"
  default     = "cae-eval-quiz"
}

variable "aca_backend_name" {
  type        = string
  description = "Nom de la Container App backend"
  default     = "ca-eval-quiz-backend"
}

variable "aca_frontend_name" {
  type        = string
  description = "Nom de la Container App frontend"
  default     = "ca-eval-quiz-frontend"
}

variable "aca_backend_image" {
  type        = string
  description = "Nom et tag de l'image backend dans l'ACR"
  default     = "eval-quiz-app-backend:latest"
}

variable "aca_frontend_image" {
  type        = string
  description = "Nom et tag de l'image frontend dans l'ACR"
  default     = "eval-quiz-app-frontend:latest"
}

variable "aca_backend_port" {
  type        = number
  description = "Port cible du conteneur backend"
  default     = 3007
}

variable "aca_frontend_port" {
  type        = number
  description = "Port cible du conteneur frontend"
  default     = 8080
}

variable "aca_cpu" {
  type        = number
  description = "CPU alloué à chaque Container App"
  default     = 0.25
}

variable "aca_memory" {
  type        = string
  description = "Mémoire allouée à chaque Container App"
  default     = "0.5Gi"
}

variable "aca_min_replicas" {
  type        = number
  description = "Nombre minimum de réplicas"
  default     = 0
}

variable "aca_max_replicas" {
  type        = number
  description = "Nombre maximum de réplicas"
  default     = 2
}

variable "log_analytics_sku" {
  type        = string
  description = "SKU du Log Analytics Workspace"
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  type        = number
  description = "Durée de rétention des logs en jours"
  default     = 30
}

variable "aca_logs_destination" {
  type        = string
  description = "Destination des logs de l'environnement Container Apps"
  default     = "log-analytics"
}

variable "aca_revision_mode" {
  type        = string
  description = "Mode de révision des Container Apps (Single ou Multiple)"
  default     = "Single"
}

variable "aca_backend_external_enabled" {
  type        = bool
  description = "Exposition externe de l'ingress backend"
  default     = true
}

variable "aca_frontend_external_enabled" {
  type        = bool
  description = "Exposition externe de l'ingress frontend"
  default     = true
}

variable "aca_ingress_transport" {
  type        = string
  description = "Protocole de transport de l'ingress (auto, http, http2, tcp)"
  default     = "auto"
}

variable "aca_traffic_percentage" {
  type        = number
  description = "Pourcentage de trafic dirigé vers la dernière révision"
  default     = 100
}

variable "aca_backend_container_name" {
  type        = string
  description = "Nom interne du conteneur backend"
  default     = "backend"
}

variable "aca_frontend_container_name" {
  type        = string
  description = "Nom interne du conteneur frontend"
  default     = "frontend"
}

variable "pg_server_name" {
  type        = string
  description = "Nom unique du serveur Azure PostgreSQL Flexible Server"
  default     = "pg-eval-quiz-34323"
}

variable "pg_db_name" {
  type        = string
  description = "Nom de la base de données PostgreSQL"
  default     = "quizdb"
}

variable "pg_admin_login" {
  type        = string
  description = "Nom d'utilisateur administrateur PostgreSQL"
  default     = "pgadmin"
}

variable "pg_version" {
  type        = string
  description = "Version majeure de PostgreSQL"
  default     = "16"
}

variable "pg_sku_name" {
  type        = string
  description = "SKU du serveur PostgreSQL Flexible Server"
  default     = "B_Standard_B1ms"
}

variable "pg_storage_mb" {
  type        = number
  description = "Taille de stockage PostgreSQL en Mo"
  default     = 32768
}