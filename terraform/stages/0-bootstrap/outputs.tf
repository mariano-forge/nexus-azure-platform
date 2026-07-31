output "resource_group_name" {
  description = "Name of the Terraform state Resource Group."
  value       = module.rg_tfstate.name
}

output "storage_account_name" {
  description = "Storage Account name — set this in the backend block of subsequent stages."
  value       = module.st_tfbackend.name
}

output "storage_account_id" {
  description = "Resource ID of the Storage Account."
  value       = module.st_tfbackend.resource_id
}

output "tfstate_container_name" {
  description = "Name of the blob container used for Terraform state files."
  value       = "tfstate"
}

output "key_vault_name" {
  description = "Name of the pipeline Key Vault (kv-platform-pipeline)."
  value       = module.kv_pipeline.name
}

output "key_vault_id" {
  description = "Resource ID of the pipeline Key Vault."
  value       = module.kv_pipeline.resource_id
}

output "key_vault_uri" {
  description = "Key Vault URI — use this in CI/CD pipelines to retrieve secrets."
  value       = module.kv_pipeline.uri
}
