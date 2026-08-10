variable "spoke_file" {
  type        = string
  description = "File name (without path) of the YAML request under spokes/. Example: phoenix-dev.yaml"
}

variable "workload_subscription_id" {
  type        = string
  description = "Subscription ID where the spoke VNet will be deployed."
}

variable "hub_subscription_id" {
  type        = string
  description = "Subscription ID hosting the hub VNet (connectivity subscription)."
}

variable "hub_vnet_id" {
  type        = string
  description = "Resource ID of the hub VNet. Consumed from hub remote state output."
}

variable "hub_vnet_name" {
  type        = string
  description = "Name of the hub VNet. Used for the hub-side peering resource."
}

variable "hub_resource_group_name" {
  type        = string
  description = "Resource group name of the hub VNet in the connectivity subscription."
}

variable "private_dns_zone_ids" {
  type        = map(string)
  default     = {}
  description = "Map of DNS zone name → resource ID from hub outputs. Required when private_dns_zone_link_enabled is true in the spoke request."
}

variable "vpn_gateway_enabled" {
  type        = bool
  default     = false
  description = "Set to true if a VPN Gateway exists in the hub. Enables use_remote_gateways on the spoke-to-hub peering."
}

variable "default_location" {
  type        = string
  default     = "francecentral"
  description = "Fallback location if not specified in the YAML request."
}

variable "enable_telemetry" {
  type        = bool
  default     = false
  description = "Enable or disable AVM telemetry."
}

variable "subnets" {
  type = map(object({
    address_prefix   = optional(string)
    address_prefixes = optional(list(string))
    name             = string
    ipam_pools = optional(list(object({
      pool_id                = string
      number_of_ip_addresses = optional(string)
      prefix_length          = optional(number)
      allocation_type        = optional(string, "Static")
    })))
    nat_gateway = optional(object({
      id = string
    }))
    network_security_group = optional(object({
      id = string
    }))
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
    route_table = optional(object({
      id = string
    }))
    service_endpoint_policies = optional(map(object({
      id = string
    })))
    service_endpoints               = optional(set(string))
    default_outbound_access_enabled = optional(bool, false)
    sharing_scope                   = optional(string, null)
    # Retained solely so that setting it produces an explanatory error instead
    # of being silently discarded during object type conversion. See the
    # validation block below. Remove in a future release.
    service_endpoints_with_location = optional(list(object({
      service   = string
      locations = optional(list(string), ["*"])
    })))
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name = string
      })
    })))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }), {})
    retry = optional(object({
      error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned"])
      interval_seconds     = optional(number, 10)
      max_interval_seconds = optional(number, 180)
    }), {})
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })))
  }))
  default     = {}
}