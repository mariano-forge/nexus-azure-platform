output "backstage_url" {
  value       = module.backstage_webapp.resource_uri
  description = "Default hostname of the App Service running Backstage."
}

output "acr_login_server" {
  value       = "${module.backstage_acr.name}.azurecr.io"
  description = "Full login server URL of the Azure Container Registry (used for image push in CI/CD)."
}

output "keyvault_name" {
  value       = module.backstage_keyvault.name
  description = "Name of the Backstage application Key Vault."
}

output "postgres_fqdn" {
  value       = azurerm_postgresql_flexible_server.backstage.fqdn
  description = "FQDN of the PostgreSQL Flexible Server (used as POSTGRES_HOST)."
}