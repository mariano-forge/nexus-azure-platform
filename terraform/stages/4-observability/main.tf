module "alz_management" {
  source  = "Azure/avm-ptn-alz-management/azurerm"
  version = "0.9.0"

  resource_group_name                                  = var.management_resource_group
  resource_group_creation_enabled                      = true
  location                                             = var.default_location
  log_analytics_workspace_local_authentication_enabled = false


  log_analytics_workspace_name = var.log_analytics_workspace_name


  automation_account_name                    = var.automation_account_name
  linked_automation_account_creation_enabled = true

  log_analytics_solution_plans = var.log_analytics_solution_plans


  user_assigned_managed_identities = {
    ama = {
      name    = "uami-ama"
      enabled = true
    }
  }

  data_collection_rules = {
    change_tracking = { name = "dcr-change-tracking", enabled = true }
    vm_insights     = { name = "dcr-vm-insights", enabled = true }
    defender_sql    = { name = "dcr-defender-sql", enabled = false } # requires Defender for SQL — out of MVP scope
  }

  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}