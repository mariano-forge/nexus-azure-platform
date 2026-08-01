variable "default_location" {
  description = "Emplacement par défaut pour les ressources"
  type        = string
  default     = "francecentral"
}

variable "management_resource_group" {
  description = "Nom du resource group de management (existant ou à créer)"
  type        = string
  default     = "ag2rlm-mgmt"
}

variable "log_analytics_workspace_name" {
  description = "Nom du Log Analytics Workspace (existant ou à créer)"
  type        = string
  default     = "ag2rlm-law"
}

variable "automation_account_name" {
  description = "Nom de l'Automation Account (existant ou à créer)"
  type        = string
  default     = "ag2rlm-aauto"
}

variable "log_analytics_solution_plans" {
  type = list(object({
    product   = string
    publisher = optional(string, "Microsoft")
  }))
}

variable "enable_telemetry" {
  type        = bool
  default     = false
  description = "Enable or disable AVM telemetry. See https://aka.ms/avm/telemetryinfo."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all connectivity resources."
  default = {
    managed-by  = "terraform"
    stage       = "connectivity"
    environment = "platform"
  }
}