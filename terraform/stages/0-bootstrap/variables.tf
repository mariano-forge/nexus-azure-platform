variable "subscription_id" {
  description = "Azure subscription ID where bootstrap resources will be created."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id))
    error_message = "subscription_id must be a valid UUID."
  }
}

variable "location" {
  description = "Azure region for all bootstrap resources."
  type        = string
  default     = "francecentral"
}

variable "prefix" {
  description = "Short prefix (3-8 chars) used to name all resources."
  type        = string
  default     = "nexus"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,7}$", var.prefix))
    error_message = "prefix must be 3-8 lowercase alphanumeric characters starting with a letter."
  }
}

variable "tags" {
  description = "Tags applied to all bootstrap resources."
  type        = map(string)
  default = {
    managed-by  = "terraform"
    stage       = "bootstrap"
    environment = "platform"
  }
}
