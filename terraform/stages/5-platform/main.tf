# -----------------------------------------------------------------------------
# App Service Plan (Linux)
# -----------------------------------------------------------------------------
module "backstage_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "2.0.8"

  parent_id = var.platform_resource_group
  name      = "asp-backstage-${var.environment}"
  location  = var.default_location
  os_type   = "Linux"
  sku_name  = "F1"

  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}

# -----------------------------------------------------------------------------
# Azure Container Registry
# -----------------------------------------------------------------------------
module "backstage_acr" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.7.0"

  name                = "acrbackstage${var.environment}"
  resource_group_name = var.platform_resource_group
  location            = var.default_location

  sku                           = "Standard"
  admin_enabled                 = false
  public_network_access_enabled = true

  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}

# -----------------------------------------------------------------------------
# Key Vault applicatif (module maison — un par workload)
# -----------------------------------------------------------------------------
module "backstage_keyvault" {
  source = "../../../modules/keyvault"

  workload_name       = "backstage"
  resource_group_name = var.platform_resource_group
  location            = var.default_location

  log_analytics_workspace_id = var.log_analytics_workspace_id

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Web App (container Linux)
# -----------------------------------------------------------------------------
module "backstage_webapp" {
  source    = "Azure/avm-res-web-site/azurerm"
  version   = "0.22.0"
  parent_id = var.platform_resource_group

  kind                     = "webapp"
  name                     = "app-backstage-${var.environment}"
  location                 = var.default_location
  service_plan_resource_id = module.backstage_service_plan.resource_id

  os_type = "Linux"

  public_network_access_enabled = true

  managed_identities = {
    system_assigned = true
  }

  key_vault_reference_identity = "SystemAssigned"

  site_config = {
    application_stack = {
      docker = {
        docker_image_name   = "backstage:latest"
        docker_registry_url = "https://${module.backstage_acr.name}.azurecr.io"
      }
    }
    container_registry_use_managed_identity = true
  }

  app_settings = {
    NODE_ENV       = "production"
    BACKEND_SECRET = "@Microsoft.KeyVault(SecretUri=${module.backstage_keyvault.secret_uri_backend_secret})"
    GITHUB_TOKEN   = "@Microsoft.KeyVault(SecretUri=${module.backstage_keyvault.secret_uri_github_token})"
  }

  diagnostic_settings = {
    to_log_analytics = {
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

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