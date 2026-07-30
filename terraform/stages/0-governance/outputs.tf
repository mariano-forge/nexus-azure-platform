# Outputs du module alz_governance

output "policy_assignment_resource_ids" {
  description = "Map des noms de policy assignments vers leurs resource IDs"
  value       = module.alz_governance.policy_assignment_resource_ids
}

output "policy_definition_resource_ids" {
  description = "Map des noms de policy definitions vers leurs resource IDs"
  value       = module.alz_governance.policy_definition_resource_ids
}

output "policy_set_definition_resource_ids" {
  description = "Map des noms de policy set definitions vers leurs resource IDs"
  value       = module.alz_governance.policy_set_definition_resource_ids
}

output "role_definition_resource_ids" {
  description = "Map des noms de role definitions vers leurs resource IDs"
  value       = module.alz_governance.role_definition_resource_ids
}

output "policy_assignment_identity_ids" {
  description = "Map des noms de policy assignments vers leurs identity IDs"
  value       = module.alz_governance.policy_assignment_identity_ids
}
