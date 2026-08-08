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

variable "private_dns_zones_enabled" {
  type        = bool
  default     = false
  description = "Deploy the full ALZ private link DNS zone set and link to the hub VNet. Set to false to skip DNS zones (cost reduction or temporary disable)."
}

variable "firewall_sku_tier" {
  type        = string
  default     = "Standard"
  description = "SKU tier for the Azure Firewall. 'Basic' automatically enables a Basic Firewall Policy (required). 'Standard' runs without a policy."

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.firewall_sku_tier)
    error_message = "firewall_sku_tier must be Basic, Standard, or Premium."
  }
}

variable "firewall_enabled" {
  type        = bool
  default     = false
  description = "Deploy Azure Firewall in the hub VNet."
}

variable "bastion_enabled" {
  type        = bool
  default     = false
  description = "Deploy Azure Bastion in the hub VNet."
}

variable "bastion_sku" {
  type        = string
  default     = "Basic"
  description = "SKU for Azure Bastion. Possible values: Basic, Standard."

  validation {
    condition     = contains(["Basic", "Standard"], var.bastion_sku)
    error_message = "bastion_sku must be Basic or Standard."
  }
}

variable "vpn_gateway_enabled" {
  type        = bool
  default     = false
  description = "Deploy a VPN Gateway in the hub VNet."
}

variable "vpn_gateway_sku" {
  type        = string
  default     = "Basic"
  description = "SKU for the VPN Gateway. Possible values: Basic (deprecated), VpnGw1, VpnGw1AZ, etc."
}