output "subscription_id" {
  description = "ID of the vended subscription."
  value       = module.subscription.subscription_id
}

output "subscription_resource_id" {
  description = "ARM resource ID of the vended subscription."
  value       = module.subscription.subscription_resource_id
}

output "resource_group_resource_ids" {
  description = "Map of created resource groups (key → resource ID)."
  value       = module.subscription.resource_group_resource_ids
}

output "management_group_subscription_association_id" {
  description = "ID of the Management Group / subscription association."
  value       = module.subscription.management_group_subscription_association_id
}

output "budget_resource_ids" {
  description = "Map of created budgets (key → resource ID)."
  value       = module.subscription.budget_resource_id
}

output "umi_resource_ids" {
  description = "Map of created User-Assigned Managed Identities (key → resource ID)."
  value       = module.subscription.umi_resource_ids
}

output "umi_principal_ids" {
  description = "Map des principal IDs des UMIs créées."
  value       = module.subscription.umi_principal_ids
}

output "umi_client_ids" {
  description = "Map des client IDs des UMIs créées."
  value       = module.subscription.umi_client_ids
}
