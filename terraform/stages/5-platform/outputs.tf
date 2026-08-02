output "backstage_url" {
  value       = module.backstage_webapp.default_hostname
  description = "URL par défaut de l'App Service hébergeant Backstage"
}

output "acr_login_server" {
  value       = module.backstage_acr.name
  description = "Nom de l'Azure Container Registry (pour le push d'image CI/CD)"
}

output "keyvault_name" {
  value       = module.backstage_keyvault.name
  description = "Nom du Key Vault applicatif de Backstage"
}