# Resource group for the spoke VNet — lives in the workload subscription.
module "rg_spoke" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.4.0"

  name             = "rg-${local.spoke_name}-network"
  location         = local.location
  enable_telemetry = var.enable_telemetry
  tags             = local.tags
}

# Spoke VNet — deployed in the workload subscription via the default provider.
# The peerings block handles the spoke→hub peering in the same subscription.
module "spoke_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.20.0"

  name             = local.spoke_name
  location         = local.location
  parent_id        = module.rg_spoke.resource_id
  address_space    = [local.address_space]
  enable_telemetry = var.enable_telemetry
  tags             = local.tags

  subnets = local.subnets

  peerings = {
    spoke-to-hub = {
      name                               = "peer-${local.spoke_name}-to-hub"
      remote_virtual_network_resource_id = var.hub_vnet_id
      allow_forwarded_traffic            = true
      allow_gateway_transit              = false
      # Only use remote gateways when a VPN Gateway exists in the hub.
      use_remote_gateways = var.vpn_gateway_enabled
      # Hub-side peering requires azurerm.hub — managed by the module below.
      create_reverse_peering = false
    }
  }
}

# Hub → spoke peering — runs in the connectivity subscription via azurerm.hub.
module "peering_hub_to_spoke" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/peering"
  version = "0.20.0"

  providers = {
    azurerm = azurerm.hub
  }

  name                      = "peer-hub-to-${local.spoke_name}"
  parent_id                 = var.hub_vnet_id
  remote_virtual_network_id = module.spoke_vnet.resource_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = var.vpn_gateway_enabled
  use_remote_gateways       = false
}

# Private DNS zone links — optional, runs in the connectivity subscription.
# Requires private_dns_zone_link_enabled = true in the YAML request
# and private_dns_zones_enabled = true in the hub stage.
resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  provider = azurerm.hub

  for_each = local.private_dns_zone_ids

  name                  = "link-${local.spoke_name}"
  resource_group_name   = var.hub_resource_group_name
  private_dns_zone_name = each.key
  virtual_network_id    = module.spoke_vnet.resource_id
  registration_enabled  = false
  tags                  = local.tags
}

