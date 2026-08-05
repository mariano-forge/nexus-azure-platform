# -----------------------------------------------------------------------------
# App Service Plan (Linux)
# -----------------------------------------------------------------------------
module "backstage_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "2.0.8"

  parent_id = var.platform_resource_group_id
  name      = "asp-${var.workload_name}-${var.environment}"
  location  = var.default_location
  os_type   = "Linux"
  sku_name  = var.app_service_plan_sku

  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}

# -----------------------------------------------------------------------------
# Azure Container Registry
# -----------------------------------------------------------------------------
module "backstage_acr" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.7.0"

  name                    = "acr${var.workload_name}${var.environment}"
  resource_group_name     = var.platform_resource_group
  location                = var.default_location
  zone_redundancy_enabled = false

  sku                           = var.acr_sku
  admin_enabled                 = false
  public_network_access_enabled = var.acr_public_network_access_enabled

  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}

# -----------------------------------------------------------------------------
# Key Vault (one per workload — see ADR-009)
# -----------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

module "backstage_keyvault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.2"

  name                = "kv-${var.workload_name}-${var.environment}"
  resource_group_name = var.platform_resource_group
  location            = var.default_location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                 = var.keyvault_sku
  purge_protection_enabled = var.keyvault_purge_protection_enabled

  # diagnostic_settings = {
  #   to_log_analytics = {
  #     workspace_resource_id = var.log_analytics_workspace_id
  #   }
  # }

  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}

# -----------------------------------------------------------------------------
# PostgreSQL Flexible Server — Backstage catalog persistence
# -----------------------------------------------------------------------------
resource "random_password" "postgres" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-password"
  value        = random_password.postgres.result
  key_vault_id = module.backstage_keyvault.resource_id
}

module "backstage_postgres" {
  source  = "Azure/avm-res-dbforpostgresql-flexibleserver/azurerm"
  version = "0.2.3"

  name                = "psql-${var.workload_name}-${var.environment}"
  resource_group_name = var.platform_resource_group
  location            = var.default_location

  administrator_login    = var.postgres_admin_login
  administrator_password = random_password.postgres.result

  sku_name       = var.postgres_sku_name
  storage_mb     = var.postgres_storage_mb
  server_version = "16"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  zone                         = "1"

  # diagnostic_settings = {
  #   to_log_analytics = {
  #     workspace_resource_id = var.log_analytics_workspace_id
  #   }
  # }

  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}

# -----------------------------------------------------------------------------
# Web App (container Linux)
# -----------------------------------------------------------------------------
module "backstage_webapp" {
  source    = "Azure/avm-res-web-site/azurerm"
  version   = "0.22.0"
  parent_id = var.platform_resource_group_id

  kind                     = "webapp"
  name                     = "app-${var.workload_name}-${var.environment}"
  location                 = var.default_location
  service_plan_resource_id = module.backstage_service_plan.resource_id

  os_type = "Linux"

  public_network_access_enabled = var.webapp_public_network_access_enabled

  managed_identities = {
    system_assigned = true
  }

  key_vault_reference_identity = "SystemAssigned"

  site_config = {
    application_stack = {
      docker = {
        docker_image_name   = var.docker_image_name
        docker_registry_url = "https://${module.backstage_acr.name}.azurecr.io"
      }
    }
    container_registry_use_managed_identity = true
  }

  app_settings = {
    NODE_ENV          = "production"
    BACKEND_SECRET    = "@Microsoft.KeyVault(SecretUri=https://${module.backstage_keyvault.name}.vault.azure.net/secrets/backend-secret/)"
    GITHUB_TOKEN      = "@Microsoft.KeyVault(SecretUri=https://${module.backstage_keyvault.name}.vault.azure.net/secrets/github-token/)"
    POSTGRES_HOST     = module.backstage_postgres.fqdn
    POSTGRES_USER     = var.postgres_admin_login
    POSTGRES_PASSWORD = "@Microsoft.KeyVault(SecretUri=https://${module.backstage_keyvault.name}.vault.azure.net/secrets/postgres-password/)"
  }

  # diagnostic_settings = {
  #   to_log_analytics = {
  #     workspace_resource_id = var.log_analytics_workspace_id
  #   }
  # }

  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}

# -----------------------------------------------------------------------------
# Role Assignment — AcrPull pour l'identité système de la Web App
# (hors module pour éviter la dépendance circulaire : l'identité n'existe
#  qu'une fois la Web App créée)
# -----------------------------------------------------------------------------
resource "azurerm_role_assignment" "acr_pull" {
  scope                = module.backstage_acr.resource_id
  role_definition_name = "AcrPull"
  principal_id         = module.backstage_webapp.system_assigned_mi_principal_id
}