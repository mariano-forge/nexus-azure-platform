output "spoke_vnet_id" {
  description = "Resource ID of the spoke VNet."
  value       = module.spoke_vnet.resource_id
}

output "spoke_vnet_name" {
  description = "Name of the spoke VNet."
  value       = module.spoke_vnet.name
}

output "spoke_resource_group_name" {
  description = "Resource group name of the spoke VNet in the workload subscription."
  value       = module.rg_spoke.name
}

output "peering_spoke_to_hub_id" {
  description = "Resource ID of the spoke-to-hub VNet peering."
  value       = module.spoke_vnet.peerings["spoke-to-hub"].resource_id
}

output "peering_hub_to_spoke_id" {
  description = "Resource ID of the hub-to-spoke VNet peering."
  value       = module.peering_hub_to_spoke.resource_id
}
