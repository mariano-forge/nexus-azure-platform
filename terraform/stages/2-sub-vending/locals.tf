locals {
  sub = yamldecode(file("${path.module}/requests/${var.subscription_name}.yaml"))

  # ── Subscription identity ────────────────────────────────────
  location                     = try(local.sub.location, var.default_location)
  subscription_alias_enabled   = try(local.sub.subscription_alias_enabled, true)
  subscription_alias_name      = try(local.sub.subscription_alias_name, null)
  subscription_display_name    = try(local.sub.subscription_display_name, null)
  subscription_billing_scope   = try(local.sub.subscription_billing_scope, var.default_billing_scope)
  subscription_workload        = try(local.sub.subscription_workload, null)
  subscription_tags            = try(local.sub.subscription_tags, {})
  subscription_update_existing = try(local.sub.subscription_update_existing, false)
  subscription_id              = try(local.sub.subscription_id, null)

  # ── Management Group ───────────────────────────────────────────────
  subscription_management_group_association_enabled = try(local.sub.subscription_management_group_association_enabled, true)
  subscription_management_group_id                  = try(local.sub.subscription_management_group_id, null)

  # ── Resource Groups ────────────────────────────────────────────────
  resource_group_creation_enabled = try(local.sub.resource_group_creation_enabled, false)
  resource_groups                 = try(local.sub.resource_groups, {})

  # ── Role Assignments ───────────────────────────────────────────────
  role_assignment_enabled = try(local.sub.role_assignment_enabled, false)
  role_assignments        = try(local.sub.role_assignments, {})

  # ── Budgets ────────────────────────────────────────────────────────
  budget_enabled = try(local.sub.budget_enabled, false)
  budgets        = try(local.sub.budgets, {})

  # ── Resource Providers ──────────────────────────────────────────────
  subscription_register_resource_providers_enabled      = try(local.sub.subscription_register_resource_providers_enabled, false)
  subscription_register_resource_providers_and_features = try(local.sub.subscription_register_resource_providers_and_features, {})

  # ── User-Assigned Managed Identities ───────────────────────────────
  user_managed_identities = try(local.sub.user_managed_identities, {})
}
