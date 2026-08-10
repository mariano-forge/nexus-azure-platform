module "rg_connectivity" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.4.0"

  name             = "rg-${var.prefix}-connectivity"
  location         = var.location
  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}

# ── NSGs ─────────────────────────────────────────────────────────────────────

module "nsg_shared" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.3"

  name                = "nsg-${var.prefix}-shared"
  resource_group_name = module.rg_connectivity.name
  location            = var.location
  security_rules      = local.nsg_rules_shared
  enable_telemetry    = var.enable_telemetry
  tags                = var.tags
}

module "nsg_private_endpoints" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.3"

  name                = "nsg-${var.prefix}-private-endpoints"
  resource_group_name = module.rg_connectivity.name
  location            = var.location
  security_rules      = local.nsg_rules_private_endpoints
  enable_telemetry    = var.enable_telemetry
  tags                = var.tags
}

# ── Hub-and-Spoke connectivity ────────────────────────────────────────────────
# ADR-002: hub-and-spoke without vWAN.
# ADR-004: no Azure Firewall — NSGs + Private Endpoints for perimeter control.
# GatewaySubnet and AzureBastionSubnet are reserved; services deployed later.
module "hub_and_spoke" {
  source  = "Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm"
  version = "~> 0.17"

  enable_telemetry = var.enable_telemetry
  tags             = var.tags

  # No shared DDoS Protection Plan in MVP.
  hub_and_spoke_networks_settings = {
    enabled_resources = {
      ddos_protection_plan = false
    }
  }

  hub_virtual_networks = {
    hub = {
      location          = var.location
      default_parent_id = module.rg_connectivity.resource_id

      enabled_resources = {
        firewall                              = var.firewall_enabled
        firewall_policy                       = var.firewall_sku_tier == "Basic" # Basic SKU requires a policy; Standard does not
        bastion                               = var.bastion_enabled
        virtual_network_gateway_express_route = false
        virtual_network_gateway_vpn           = var.vpn_gateway_enabled
        private_dns_zones                     = var.private_dns_zones_enabled
        private_dns_resolver                  = false
        dns_resolver_policy                   = false
        nat_gateway                           = false
      }

      hub_virtual_network = {
        name          = "vnet-hub-${var.prefix}-${var.location}"
        address_space = [var.hub_address_space]
        # No auto-generated route tables — no firewall to route through.
        route_table_firewall_enabled     = var.firewall_enabled
        route_table_user_subnets_enabled = false
        tags                             = var.tags

        subnets = {
          snet-shared = {
            name             = "snet-shared"
            address_prefixes = [local.snet_shared]
            network_security_group = {
              id = module.nsg_shared.resource_id
            }
          }
          snet-private-endpoints = {
            name                                      = "snet-private-endpoints"
            address_prefixes                          = [local.snet_private_endpoints]
            private_endpoint_network_policies_enabled = false
            network_security_group = {
              id = module.nsg_private_endpoints.resource_id
            }
          }
        }
      }

      private_dns_zones = {
        # No auto-registration zone (not needed for platform resources).
        auto_registration_zone_enabled = false
        # The module deploys the full ALZ private link DNS zone set and
        # links all zones to the hub VNet automatically.
      }

      # Explicit CIDRs prevent the module's auto-allocator from conflicting with our custom subnets.
      # Custom subnets occupy: 10.0.0.0/27, 10.0.0.64/26, 10.0.2.0/24, 10.0.3.0/24
      firewall = {
        sku_tier                         = var.firewall_sku_tier
        subnet_address_prefix            = cidrsubnet(var.hub_address_space, 10, 4) # 10.0.1.0/26
        management_subnet_address_prefix = cidrsubnet(var.hub_address_space, 10, 5) # 10.0.1.64/26
      }

      firewall_policy = var.firewall_sku_tier == "Basic" ? { sku = "Basic" } : null

      bastion = {
        sku                   = var.bastion_sku
        subnet_address_prefix = local.snet_bastion # module manages AzureBastionSubnet
      }

      virtual_network_gateways = {
        subnet_address_prefix = local.snet_gateway # module manages GatewaySubnet
        vpn                   = { sku = var.vpn_gateway_sku }
      }
    }
  }
}
