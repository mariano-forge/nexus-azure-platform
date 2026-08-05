variable "environment" {
  type        = string
  description = "Environment (dev, test, prod)"
}

variable "default_location" {
  type        = string
  description = "Azure region"
}

variable "platform_resource_group" {
  type        = string
  description = "Name of the resource group hosting the platform stage resources."
}

variable "platform_resource_group_id" {
  type        = string
  description = "Resource ID of the platform resource group (used as parent_id for AVM modules)."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace (from 4-observability) — temporary input var until naming convention lets us resolve this via a data source"
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
  description = "Allow public network access to the ACR. Set to false once a Private Endpoint is in place."
  default     = false
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

variable "docker_image_name" {
  type        = string
  description = "Docker image to deploy on the Web App (e.g. 'backstage:1.2.3')."
  default     = "backstage:latest"
}

variable "postgres_admin_login" {
  type        = string
  description = "Administrator login for the PostgreSQL Flexible Server."
  default     = "backstageadmin"
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