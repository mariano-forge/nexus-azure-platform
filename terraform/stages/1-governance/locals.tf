locals {
  # Single source of truth for all management group IDs — derived from var.root_id.
  mg = merge(
    {
      root         = var.root_id
      connectivity = "${var.root_id}-connectivity"
      corp         = "${var.root_id}-corp"
      landingzones = "${var.root_id}-landingzones"
      management   = "${var.root_id}-management"
      online       = "${var.root_id}-online"
      platform     = "${var.root_id}-platform"
    },
    var.management_groups_config.include_identity ? { identity = "${var.root_id}-identity" } : {},
    var.management_groups_config.include_decommissioned ? { decommissioned = "${var.root_id}-decommissioned" } : {},
    var.management_groups_config.include_local ? { lz_local = "${var.root_id}-local" } : {},
    var.management_groups_config.include_sandboxes ? { sandboxes = "${var.root_id}-sandboxes" } : {},
    var.management_groups_config.include_security ? { security = "${var.root_id}-security" } : {}
  )

  # Reviewed against ADR-013: only policies that depend on infrastructure not yet
  # deployed (Log Analytics / Defender / Recovery Services Vault / Customer-Managed
  # Keys) stay disabled. Pure deny/audit policies with no external dependency are
  # enabled from day one. To re-enable a policy once its dependency lands
  # (e.g. 3-observability ships a real Log Analytics Workspace), remove its entry
  # from the relevant list below.
  _mvp_disabled_assignments = merge(
    {
      (local.mg.root) = [
        # Depend on Log Analytics / Defender for Cloud (not deployed until 3-observability)
        "Deploy-ASC-Monitoring",
        "Deploy-AzActivity-Log",
        "Deploy-Diag-LogsCat",
        "Deploy-MCSB2-Monitoring",
        "Deploy-MDEndpoints",
        "Deploy-MDEndpointsAMA",
        "Deploy-MDFC-Config-H224",
        "Deploy-MDFC-OssDb",
        "Deploy-MDFC-SqlAtp",
        # Depends on an Action Group / notification target not configured yet
        "Deploy-SvcHealth-BuiltIn",
        # Depends on Guest Configuration / Automation, deferred with observability
        "Enforce-ACSB",
      ]
      (local.mg.connectivity) = [
        # Cost decision (ADR-012), not a dependency gap — stays disabled deliberately
        "Enable-DDoS-VNET",
      ]
      (local.mg.corp) = [
        # Nothing disabled here — Deploy-Private-DNS-Zones, Deny-Public-Endpoints,
        # Deny-Public-IP-On-NIC, Audit-PeDnsZones, Deny-HybridNetworking have no
        # external dependency and are core to the Private Endpoints architecture (ADR-004).
      ]
      (local.mg.landingzones) = [
        # Depend on Log Analytics / Defender / Recovery Services Vault / ASR
        "Deploy-AzSqlDb-Auditing",
        "Deploy-MDFC-DefSQL-AMA",
        "Deploy-SQL-Threat",
        "Deploy-VM-Backup", # needs a Recovery Services Vault
        "Deploy-VM-ChangeTrack",
        "Deploy-VM-Monitoring",
        "Deploy-VMSS-ChangeTrack",
        "Deploy-VMSS-Monitoring",
        "Deploy-vmArc-ChangeTrack",
        "Deploy-vmHybr-Monitoring",
        "Enforce-ASR",
        # Cost decision (ADR-012), same as connectivity
        "Enable-DDoS-VNET",
        # Needs a Customer-Managed Key configured per service — not in current scope
        "Enforce-Encrypt-CMK0",
      ]
      (local.mg.platform) = [
        # Same dependency-based exclusions as landingzones
        "Deploy-MDFC-DefSQL-AMA",
        "Deploy-VM-ChangeTrack",
        "Deploy-VM-Monitoring",
        "Deploy-VMSS-ChangeTrack",
        "Deploy-VMSS-Monitoring",
        "Deploy-vmArc-ChangeTrack",
        "Deploy-vmHybr-Monitoring",
        "Enforce-ASR",
        "Enforce-Encrypt-CMK0",
      ]
    },
    # Optional MGs — only included when the MG exists in local.mg
    {
      for mg_key, assignments in {
        "identity" = [
          # Same Recovery Services Vault gap as landingzones/platform
          "Deploy-VM-Backup"
        ]
        "sandboxes"      = []
        "decommissioned" = []
        # Unverified policy name — confirm against the alz-library catalog before
        # deciding; left disabled pending verification rather than assumed safe.
        "lz_local" = [
          "Enforce-ALDO-Services"
        ]
      } : local.mg[mg_key] => assignments
      if contains(keys(local.mg), mg_key)
    }
  )

  # var.policy_assignments_to_modify takes precedence within each MG (e.g. to set enforcement_mode instead of disabling).
  _disabled_by_mg = {
    for mg, assignments in local._mvp_disabled_assignments :
    mg => {
      policy_assignments = {
        for assignment in assignments : assignment => { creation_enabled = false }
      }
    }
  }

  effective_policy_assignments_to_modify = {
    for mg in toset(concat(keys(local._disabled_by_mg), keys(var.policy_assignments_to_modify))) :
    mg => {
      policy_assignments = merge(
        try(local._disabled_by_mg[mg].policy_assignments, {}),
        try(var.policy_assignments_to_modify[mg].policy_assignments, {})
      )
    }
  }
}
