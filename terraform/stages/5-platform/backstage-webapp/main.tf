locals {
  backstage_url = coalesce(var.backstage_base_url, "https://app-${var.workload_name}-${var.environment}-${random_string.webapp_suffix.result}.azurewebsites.net")
}

module "rg_backstage" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.4.0"

  name             = "rg-${var.workload_name}-${var.environment}"
  location         = var.location
  enable_telemetry = false
  tags             = var.tags
}

# -----------------------------------------------------------------------------
# App Service Plan (Linux)
# -----------------------------------------------------------------------------
module "backstage_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "2.0.8"

  parent_id              = module.rg_backstage.resource_id
  name                   = "asp-${var.workload_name}-${var.environment}"
  location               = var.location
  os_type                = "Linux"
  sku_name               = var.app_service_plan_sku
  zone_balancing_enabled = false # Basic SKU does not support zone redundancy

  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}

# -----------------------------------------------------------------------------
# Azure Container Registry
# -----------------------------------------------------------------------------
# ACR names are globally unique — suffix prevents DNS conflict
resource "random_string" "acr_suffix" {
  length  = 4
  upper   = false
  special = false
  keepers = { workload = var.workload_name, environment = var.environment }

  lifecycle {
    ignore_changes = [keepers] # prevents recreation of existing resources; remove for new deployments
  }
}

resource "random_string" "kv_suffix" {
  length  = 2
  upper   = false
  special = false
}

resource "random_string" "webapp_suffix" {
  length  = 2
  upper   = false
  special = false
}

module "backstage_acr" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.7.0"

  name                    = "acr${var.workload_name}${var.environment}${random_string.acr_suffix.result}"
  resource_group_name     = module.rg_backstage.name
  location                = var.location
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

  name                = "kv-${var.workload_name}-${var.environment}-${random_string.kv_suffix.result}"
  resource_group_name = module.rg_backstage.name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                 = var.keyvault_sku
  purge_protection_enabled = var.keyvault_purge_protection_enabled

  # Allow all by default — restrict to Private Endpoint once connectivity stage is peered
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  role_assignments = {
    terraform_operator = {
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = data.azurerm_client_config.current.object_id
      principal_type             = "User"
    }
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
# PostgreSQL Flexible Server — Backstage catalog persistence
# -----------------------------------------------------------------------------
# PostgreSQL server names are globally unique — suffix prevents collision
resource "random_string" "postgres_suffix" {
  length  = 4
  upper   = false
  special = false
  keepers = { workload = var.workload_name, environment = var.environment }

  lifecycle {
    ignore_changes = [keepers] # prevents recreation of existing resources; remove for new deployments
  }
}

resource "random_password" "postgres" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-password"
  value        = random_password.postgres.result
  key_vault_id = module.backstage_keyvault.resource_id

  # Wait for the full module (including role assignment RBAC propagation) before writing the secret
  depends_on = [module.backstage_keyvault]

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_key_vault_secret" "github_client_id" {
  name         = "github-client-id"
  value        = var.github_client_id
  key_vault_id = module.backstage_keyvault.resource_id

  # Wait for the full module (including role assignment RBAC propagation) before writing the secret
  depends_on = [module.backstage_keyvault]

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_key_vault_secret" "github_client_secret" {
  name         = "github-client-secret"
  value        = var.github_client_secret
  key_vault_id = module.backstage_keyvault.resource_id

  # Wait for the full module (including role assignment RBAC propagation) before writing the secret
  depends_on = [module.backstage_keyvault]

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_key_vault_secret" "github_token" {
  name         = "github-token"
  value        = var.github_token
  key_vault_id = module.backstage_keyvault.resource_id

  # Wait for the full module (including role assignment RBAC propagation) before writing the secret
  depends_on = [module.backstage_keyvault]

  lifecycle {
    prevent_destroy = true
  }
}

# Direct resource instead of AVM module — AVM 0.2.3 forces HA which is incompatible with Burstable SKU
resource "azurerm_postgresql_flexible_server" "backstage" {
  name                = "psql-${var.workload_name}-${var.environment}-${random_string.postgres_suffix.result}"
  resource_group_name = module.rg_backstage.name
  location            = var.location

  administrator_login    = var.postgres_admin_login
  administrator_password = random_password.postgres.result

  sku_name   = var.postgres_sku_name
  storage_mb = var.postgres_storage_mb
  version    = "16"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  zone                         = "1"

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Web App (container Linux)
# -----------------------------------------------------------------------------
module "backstage_webapp" {
  source    = "Azure/avm-res-web-site/azurerm"
  version   = "0.22.0"
  parent_id = module.rg_backstage.resource_id

  kind                     = "webapp"
  name                     = "app-${var.workload_name}-${var.environment}-${random_string.webapp_suffix.result}"
  location                 = var.location
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
        docker_registry_url = module.backstage_acr.login_server
      }
    }
    # Managed Identity auth only applies to ACR — disabled when using a public registry
    container_registry_use_managed_identity = var.container_registry_use_managed_identity
  }

  app_settings = {

    ORG_NAME       = var.org_name
    OWNER_USERNAME = var.owner_username
    APP_TITLE      = var.app_title

    WEBSITES_PORT    = var.app_port
    NODE_ENV         = var.node_env
    APP_BASE_URL     = local.backstage_url
    BACKEND_BASE_URL = local.backstage_url

    BACKEND_SECRET       = "@Microsoft.KeyVault(SecretUri=https://${module.backstage_keyvault.name}.vault.azure.net/secrets/backend-secret/)"
    GITHUB_CLIENT_ID     = "@Microsoft.KeyVault(SecretUri=https://${module.backstage_keyvault.name}.vault.azure.net/secrets/github-client-id/)"
    GITHUB_CLIENT_SECRET = "@Microsoft.KeyVault(SecretUri=https://${module.backstage_keyvault.name}.vault.azure.net/secrets/github-client-secret/)"
    GITHUB_TOKEN         = "@Microsoft.KeyVault(SecretUri=https://${module.backstage_keyvault.name}.vault.azure.net/secrets/github-token/)"
    POSTGRES_HOST        = azurerm_postgresql_flexible_server.backstage.fqdn
    POSTGRES_USER        = var.postgres_admin_login
    POSTGRES_PASSWORD    = "@Microsoft.KeyVault(SecretUri=https://${module.backstage_keyvault.name}.vault.azure.net/secrets/postgres-password/)"
    POSTGRES_PORT        = var.postgres_port
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
# Role Assignments
# -----------------------------------------------------------------------------
resource "azurerm_role_assignment" "acr_pull" {
  scope                = module.backstage_acr.resource_id
  role_definition_name = "AcrPull"
  principal_id         = module.backstage_webapp.system_assigned_mi_principal_id
}

# Allow the Web App's managed identity to resolve Key Vault references
resource "azurerm_role_assignment" "webapp_kv_secrets" {
  scope                = module.backstage_keyvault.resource_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.backstage_webapp.system_assigned_mi_principal_id
}

# Allow App Service to reach PostgreSQL — 0.0.0.0/0.0.0.0 is the Azure convention for "Allow Azure services"
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "AllowAllAzureServicesAndResourcesWithinAzureIps"
  server_id        = azurerm_postgresql_flexible_server.backstage.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}