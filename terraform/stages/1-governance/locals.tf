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

  # MVP: all standard ALZ policy assignments disabled — re-enable individually as the platform matures.
  # To re-enable a policy, remove its entry from the relevant list below.
  _mvp_disabled_assignments = merge(
    {
      (local.mg.root) = [
        "Audit-ResourceRGLocation",
        "Audit-TrustedLaunch",
        "Audit-UnusedResources",
        "Audit-ZoneResiliency",
        "Deny-Classic-Resources",
        "Deny-UnmanagedDisk",
        "Deploy-ASC-Monitoring",
        "Deploy-AzActivity-Log",
        "Deploy-Diag-LogsCat",
        "Deploy-MCSB2-Monitoring",
        "Deploy-MDEndpoints",
        "Deploy-MDEndpointsAMA",
        "Deploy-MDFC-Config-H224",
        "Deploy-MDFC-OssDb",
        "Deploy-MDFC-SqlAtp",
        "Deploy-SvcHealth-BuiltIn",
        "Enforce-ACSB",
      ]
      (local.mg.connectivity) = [
        "Enable-DDoS-VNET",
      ]
      (local.mg.corp) = [
        "Audit-PeDnsZones",
        "Deny-HybridNetworking",
        "Deny-Public-Endpoints",
        "Deny-Public-IP-On-NIC",
        "Deploy-Private-DNS-Zones",
      ]
      (local.mg.landingzones) = [
        "Audit-AppGW-WAF",
        "Deny-IP-forwarding",
        "Deny-MgmtPorts-Internet",
        "Deny-Priv-Esc-AKS",
        "Deny-Privileged-AKS",
        "Deny-Storage-http",
        "Deny-Subnet-Without-Nsg",
        "Deploy-AzSqlDb-Auditing",
        "Deploy-GuestAttest",
        "Deploy-MDFC-DefSQL-AMA",
        "Deploy-SQL-TDE",
        "Deploy-SQL-Threat",
        "Deploy-VM-Backup",
        "Deploy-VM-ChangeTrack",
        "Deploy-VM-Monitoring",
        "Deploy-VMSS-ChangeTrack",
        "Deploy-VMSS-Monitoring",
        "Deploy-vmArc-ChangeTrack",
        "Deploy-vmHybr-Monitoring",
        "Enable-AUM-CheckUpdates",
        "Enable-DDoS-VNET",
        "Enforce-AKS-HTTPS",
        "Enforce-ASR",
        "Enforce-Encrypt-CMK0",
        "Enforce-GR-APIM0",
        "Enforce-GR-AppServices0",
        "Enforce-GR-Automation0",
        "Enforce-GR-BotService0",
        "Enforce-GR-CogServ0",
        "Enforce-GR-Compute0",
        "Enforce-GR-ContApps0",
        "Enforce-GR-ContInst0",
        "Enforce-GR-ContReg0",
        "Enforce-GR-CosmosDb0",
        "Enforce-GR-DataExpl0",
        "Enforce-GR-DataFactory0",
        "Enforce-GR-EventGrid0",
        "Enforce-GR-EventHub0",
        "Enforce-GR-KeyVault",
        "Enforce-GR-KeyVaultSup0",
        "Enforce-GR-Kubernetes0",
        "Enforce-GR-MachLearn0",
        "Enforce-GR-MySQL0",
        "Enforce-GR-Network0",
        "Enforce-GR-OpenAI0",
        "Enforce-GR-PostgreSQL0",
        "Enforce-GR-SQL0",
        "Enforce-GR-ServiceBus0",
        "Enforce-GR-Storage0",
        "Enforce-GR-Synapse0",
        "Enforce-GR-VirtualDesk0",
        "Enforce-Subnet-Private",
        "Enforce-TLS-SSL-Q225",
      ]
      (local.mg.platform) = [
        "DenyAction-DeleteUAMIAMA",
        "Deploy-GuestAttest",
        "Deploy-MDFC-DefSQL-AMA",
        "Deploy-VM-ChangeTrack",
        "Deploy-VM-Monitoring",
        "Deploy-VMSS-ChangeTrack",
        "Deploy-VMSS-Monitoring",
        "Deploy-vmArc-ChangeTrack",
        "Deploy-vmHybr-Monitoring",
        "Enable-AUM-CheckUpdates",
        "Enforce-ASR",
        "Enforce-Encrypt-CMK0",
        "Enforce-GR-APIM0",
        "Enforce-GR-AppServices0",
        "Enforce-GR-Automation0",
        "Enforce-GR-BotService0",
        "Enforce-GR-CogServ0",
        "Enforce-GR-Compute0",
        "Enforce-GR-ContApps0",
        "Enforce-GR-ContInst0",
        "Enforce-GR-ContReg0",
        "Enforce-GR-CosmosDb0",
        "Enforce-GR-DataExpl0",
        "Enforce-GR-DataFactory0",
        "Enforce-GR-EventGrid0",
        "Enforce-GR-EventHub0",
        "Enforce-GR-KeyVault",
        "Enforce-GR-KeyVaultSup0",
        "Enforce-GR-Kubernetes0",
        "Enforce-GR-MachLearn0",
        "Enforce-GR-MySQL0",
        "Enforce-GR-Network0",
        "Enforce-GR-OpenAI0",
        "Enforce-GR-PostgreSQL0",
        "Enforce-GR-SQL0",
        "Enforce-GR-ServiceBus0",
        "Enforce-GR-Storage0",
        "Enforce-GR-Synapse0",
        "Enforce-GR-VirtualDesk0",
        "Enforce-Subnet-Private",
      ]
    },
    # Optional MGs — only included when the MG exists in local.mg
    {
      for mg_key, assignments in {
        "identity" = [
          "Deny-MgmtPorts-Internet",
          "Deny-Public-IP", "Deny-Subnet-Without-Nsg",
          "Deploy-VM-Backup"
        ]
        "sandboxes" = [
          "Enforce-ALZ-Sandbox"
        ]
        # decommissioned, local, security have no default ALZ policies to disable
        "decommissioned" = [
          "Enforce-ALZ-Decomm"
        ]
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