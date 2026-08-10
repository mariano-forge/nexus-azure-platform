output "hub_vnet_id" {
  description = "Resource ID of the hub VNet."
  value       = module.hub_and_spoke.resource_id["hub"]
}

output "hub_vnet_name" {
  description = "Name of the hub VNet."
  value       = module.hub_and_spoke.name["hub"]
}

output "hub_subscription_id" {
  description = "Subscription ID hosting the hub VNet — consumed by spoke-vending for cross-subscription peering."
  value       = module.rg_connectivity.resource_id == null ? null : regex("/subscriptions/([^/]+)/", module.rg_connectivity.resource_id)[0]
}

# Subnet IDs are deterministic: <vnet_id>/subnets/<name>
output "subnet_ids" {
  description = "Map of subnet name → resource ID for all hub subnets."
  value = {
    for name in ["GatewaySubnet", "AzureBastionSubnet", "snet-shared", "snet-private-endpoints"] :
    name => "${module.hub_and_spoke.resource_id["hub"]}/subnets/${name}"
  }
}

output "private_dns_zone_ids" {
  description = "Map of DNS zone name → resource ID (all ALZ private link zones)."
  value       = module.hub_and_spoke.private_dns_zone_resource_ids
}

output "resource_group_name" {
  description = "Name of the connectivity resource group."
  value       = module.rg_connectivity.name
}

output "resource_group_id" {
  description = "Resource ID of the connectivity resource group."
  value       = module.rg_connectivity.resource_id
}
