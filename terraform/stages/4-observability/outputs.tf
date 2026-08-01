output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace."
  value       = module.alz_management.log_analytics_workspace.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace."
  value       = module.alz_management.log_analytics_workspace.name
}

output "automation_account_id" {
  description = "Resource ID of the Automation Account (used by M3 runbooks)."
  value       = module.alz_management.automation_account.id
}

output "resource_group_name" {
  description = "Name of the management resource group."
  value       = module.alz_management.resource_group_name
}