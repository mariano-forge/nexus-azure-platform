output "policy_assignment_resource_ids" {
  description = "Map of policy assignment names to their resource IDs."
  value       = module.alz_governance.policy_assignment_resource_ids
}

output "policy_definition_resource_ids" {
  description = "Map of policy definition names to their resource IDs."
  value       = module.alz_governance.policy_definition_resource_ids
}

output "policy_set_definition_resource_ids" {
  description = "Map of policy set definition names to their resource IDs."
  value       = module.alz_governance.policy_set_definition_resource_ids
}

output "role_definition_resource_ids" {
  description = "Map of role definition names to their resource IDs."
  value       = module.alz_governance.role_definition_resource_ids
}

output "policy_assignment_identity_ids" {
  description = "Map of policy assignment names to their managed identity IDs."
  value       = module.alz_governance.policy_assignment_identity_ids
}
