variable "prefix" {
  type        = string
  default     = "nexus"
  description = "Short prefix (3-8 chars) used in all resource names."

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,7}$", var.prefix))
    error_message = "prefix must be 3-8 lowercase alphanumeric characters starting with a letter."
  }
}

variable "location" {
  type        = string
  default     = "francecentral"
  description = "Azure region for all connectivity resources."
}

variable "hub_address_space" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the hub VNet. Must be at least /16 to fit the fixed subnet layout."

  validation {
    condition     = can(cidrnetmask(var.hub_address_space))
    error_message = "hub_address_space must be a valid CIDR block."
  }
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

variable "enable_telemetry" {
  type        = bool
  default     = false
  description = "Enable or disable AVM telemetry. See https://aka.ms/avm/telemetryinfo."
}
