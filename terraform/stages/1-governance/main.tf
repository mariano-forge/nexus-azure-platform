data "azapi_client_config" "current" {}

module "alz_governance" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "0.21.0"

  architecture_name  = var.root_id
  location           = var.default_location
  parent_resource_id = data.azapi_client_config.current.tenant_id

  delays = {}

  management_group_hierarchy_settings = {
    default_management_group_name            = coalesce(var.default_management_group_name, lookup(local.mg, "sandboxes", null), local.mg.root)
    require_authorization_for_group_creation = true
    update_existing                          = true
  }

  subscription_placement = var.subscription_placement

  policy_assignments_to_modify = local.effective_policy_assignments_to_modify
  policy_assignment_non_compliance_message_settings = {
    merge_mode = "prefer_existing"
  }

  policy_default_values             = var.policy_default_values
  management_group_role_assignments = var.management_group_role_assignments
  resource_types                    = var.resource_types
  enable_telemetry                  = var.enable_telemetry
}