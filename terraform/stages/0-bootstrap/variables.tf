variable "subscription_id" {
  description = "Azure subscription ID where bootstrap resources will be created."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id))
    error_message = "subscription_id must be a valid UUID."
  }
}

variable "tenant_id" {
  description = "Azure tenant ID where bootstrap resources will be created. If null, uses the current authenticated tenant."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.tenant_id))
    error_message = "tenant_id must be a valid UUID."
  }
}

variable "principal_id" {
  description = "Object ID of the principal (user/service principal) running the bootstrap."
  type        = string
  sensitive   = true
  default     = null

  validation {
    condition     = var.principal_id == null ? true : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.principal_id))
    error_message = "principal_id must be a valid UUID or null."
  }
}


variable "principal_type" {
  description = "Type of the principal (User, ServicePrincipal, ManagedIdentity) running the bootstrap."
  type        = string

  validation {
    condition     = contains(["User", "ServicePrincipal", "ManagedIdentity"], var.principal_type)
    error_message = "principal_type must be one of: User, ServicePrincipal, ManagedIdentity."
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
