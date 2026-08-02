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
  description = "Resource group hosting the platform stage resources"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the Log Analytics workspace (from 4-observability) — temporary input var until naming convention lets us resolve this via a data source"
}

variable "enable_telemetry" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}