variable "environment" {
  type        = string
  description = "Environment (dev, test, prod)"
}

variable "location" {
  type        = string
  description = "Azure region."
}

# variable "platform_resource_group" {
#   type        = string
#   description = "Name of the resource group hosting the platform stage resources."
# }

# variable "platform_resource_group_id" {
#   type        = string
#   description = "Resource ID of the platform resource group (used as parent_id for AVM modules)."
# }

# tflint-ignore: terraform_unused_declarations -- kept for when diagnostic_settings blocks are uncommented
variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace (from 4-observability) — temporary input var until naming convention lets us resolve this via a data source"
  default     = ""
}

variable "workload_name" {
  type        = string
  description = "Short name used in all resource names for this workload (e.g. 'backstage')."
  default     = "backstage"
}

variable "app_service_plan_sku" {
  type        = string
  description = "SKU for the App Service Plan. Minimum B1 for Linux containers."
  default     = "B1"
}

variable "acr_sku" {
  type        = string
  description = "SKU for the Azure Container Registry (Basic, Standard, Premium)."
  default     = "Standard"
}

variable "keyvault_sku" {
  type        = string
  description = "SKU for the Key Vault (standard or premium)."
  default     = "standard"
}

variable "acr_public_network_access_enabled" {
  type        = bool
  description = "Allow public network access to the ACR. Requires Premium SKU to disable."
  default     = true
}

variable "webapp_public_network_access_enabled" {
  type        = bool
  description = "Allow public network access to the Web App."
  default     = true
}

variable "keyvault_purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection on the Key Vault. Disable only in non-production environments."
  default     = true
}

variable "app_port" {
  type        = string
  description = "Port the Backstage backend listens on. Must match WEBSITES_PORT."
  default     = "7007"
}

variable "node_env" {
  type        = string
  description = "Node.js environment (production, development)."
  default     = "production"
}

variable "backstage_base_url" {
  type        = string
  description = "Public HTTPS URL of the Backstage App Service. Used for both APP_BASE_URL and BACKEND_BASE_URL."
  default     = null
}

variable "docker_image_name" {
  type        = string
  description = "Docker image to deploy on the Web App. Do not include the tag — the module appends ':latest' automatically."
  default     = "backstage"
}

# variable "docker_registry_url" {
#   type        = string
#   description = "URL of the container registry. Use 'https://ghcr.io' for the public demo image, or 'https://<acr>.azurecr.io' for ACR."
#   default     = "https://ghcr.io"
# }

variable "container_registry_use_managed_identity" {
  type        = bool
  description = "Set to true only when docker_registry_url points to ACR (requires AcrPull role assignment)."
  default     = false
}

variable "postgres_admin_login" {
  type        = string
  description = "Administrator login for the PostgreSQL Flexible Server."
  default     = "backstageadmin"
}

variable "postgres_port" {
  type        = string
  description = "Port for the PostgreSQL Flexible Server."
  default     = "5432"
}
variable "postgres_sku_name" {
  type        = string
  description = "SKU for the PostgreSQL Flexible Server (e.g. B_Standard_B1ms for dev, GP_Standard_D2s_v3 for prod)."
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  type        = number
  description = "Storage size in MB for the PostgreSQL Flexible Server."
  default     = 32768
}

variable "enable_telemetry" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "github_client_id" {
  type        = string
  description = "GitHub OAuth App Client ID for Backstage authentication."
  default     = null
}

variable "github_client_secret" {
  type        = string
  description = "GitHub OAuth App Client Secret for Backstage authentication."
  default     = null
}

variable "github_token" {
  type        = string
  description = "GitHub Personal Access Token for Backstage to access GitHub APIs."

}

variable "org_name" {
  type        = string
  description = "GitHub organization name for Backstage."

}

variable "owner_username" {
  type        = string
  description = "GitHub username of the owner for Backstage."
}

variable "app_title" {
  type        = string
  description = "Title of the Backstage application."
}