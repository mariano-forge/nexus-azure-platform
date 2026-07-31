module "subscription" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "0.3.0"

  location = local.location

  # ── Subscription identity ────────────────────────────────────────────
  subscription_alias_enabled   = local.subscription_alias_enabled
  subscription_alias_name      = local.subscription_alias_name
  subscription_display_name    = local.subscription_display_name
  subscription_billing_scope   = local.subscription_billing_scope
  subscription_workload        = local.subscription_workload
  subscription_tags            = local.subscription_tags
  subscription_update_existing = local.subscription_update_existing
  subscription_id              = local.subscription_id

  # ── Management Group ────────────────────────────────────────────────
  subscription_management_group_association_enabled = local.subscription_management_group_association_enabled
  subscription_management_group_id                  = local.subscription_management_group_id

  # ── Resource Groups ─────────────────────────────────────────────────
  resource_group_creation_enabled = local.resource_group_creation_enabled
  resource_groups                 = local.resource_groups

  # ── Role Assignments ────────────────────────────────────────────────
  role_assignment_enabled = local.role_assignment_enabled
  role_assignments        = local.role_assignments

  # ── Budgets ─────────────────────────────────────────────────────────
  budget_enabled = local.budget_enabled
  budgets        = local.budgets

  # ── Resource Providers ────────────────────────────────────────────────
  subscription_register_resource_providers_enabled      = local.subscription_register_resource_providers_enabled
  subscription_register_resource_providers_and_features = local.subscription_register_resource_providers_and_features

  # ── User-Assigned Managed Identities ────────────────────────────────
  umi_enabled             = length(local.user_managed_identities) > 0
  user_managed_identities = local.user_managed_identities

  # Networking is out of scope for this stage — handled in stage 3-networking.
  virtual_network_enabled        = false
  network_security_group_enabled = false
  route_table_enabled            = false

  enable_telemetry = var.enable_telemetry
}
