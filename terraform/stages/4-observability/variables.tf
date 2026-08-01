variable "default_location" {
  description = "Default Azure region for all observability resources."
  type        = string
  default     = "francecentral"
}

variable "management_resource_group" {
  description = "Name of the management resource group (created if it does not exist)."
  type        = string
  default     = "rg-nexus-management"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace (created if it does not exist)."
  type        = string
  default     = "law-nexus-platform"
}

variable "automation_account_name" {
  description = "Name of the Automation Account (created if it does not exist)."
  type        = string
  default     = "aa-nexus-platform"
}

variable "log_analytics_solution_plans" {
  type = list(object({
    product   = string
    publisher = optional(string, "Microsoft")
  }))
  default = []
}

variable "enable_telemetry" {
  type        = bool
  default     = false
  description = "Enable or disable AVM telemetry. See https://aka.ms/avm/telemetryinfo."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all management resources."
  default = {
    managed-by  = "terraform"
    stage       = "management"
    environment = "platform"
  }
}