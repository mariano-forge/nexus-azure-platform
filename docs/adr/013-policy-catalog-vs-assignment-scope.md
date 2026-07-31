# ADR-013: Policy Catalog Breadth vs. Assignment Scope

**Status:** ✅ Accepted  
**Date:** 2026-07-21  
**Author:** Mariano Gbego  
**Context:** Nexus Azure Platform

---

## Context

The default `architecture_name` shipped with the AVM governance pattern module (`avm-ptn-alz`, see [ADR-012](012-avm-pattern-modules.md)) generates the full "enterprise-scale" archetype: 149 policy definitions, 42 policy set definitions, and 121 policy assignments (194 downstream policy role assignments) — 527 resources in total on a first `terraform plan`.

Applying this as-is produced 70 `PolicyRoleAssignmentError` failures.
All of them come from the same family of assignments (`Deploy-MCSB2-Monitoring` and related diagnostic-settings policies), which try to create role assignments scoped to a Log Analytics Workspace, an Event Hub authorization rule, or a Storage Account — none of which exist yet, because `3-observability` has not been deployed at the point `1-governance` is applied.

Investigating the full set of failing and not-yet-failing assignments further revealed a broader issue: most of the 121 standard ALZ assignments either require infrastructure that doesn't exist yet (diagnostic destinations, MDFC plans, DDoS protection plans), or would enforce controls that the MVP platform isn't ready to comply with yet (network restrictions, encryption at rest requirements, etc.).

The question this ADR resolves: should the policy **catalog** (definitions/policy set definitions) be trimmed down to match what's assigned today, or should the catalog stay complete while **all standard ALZ assignments** are deferred until the platform is ready for them?

---

## Decision

We keep the **full policy and policy set definition catalog** from the default architecture — every definition remains available in the custom `mariano-forge` architecture this project ships, so anyone cloning this repo has the complete enterprise-scale policy set ready to assign.

We **disable all standard ALZ policy assignments** at MVP using `creation_enabled = false` via the module's `policy_assignments_to_modify` input. This is implemented in `terraform/stages/1-governance/locals.tf` as `_mvp_disabled_assignments`, a map listing every default ALZ assignment per management group that is not yet appropriate for the current platform state.

The only active assignments are two custom tag-audit policies (`Audit-Tags-Mandatory`, `Audit-Tags-Mandatory-Rg`) defined locally in `lib/policy_assignments/` and assigned at the root management group via the `root_override` archetype.

The mechanism used — `creation_enabled = false` — is the correct API for this: the module generates the full `terraform plan` resource graph but skips creation for flagged assignments, keeping the plan clean and the state consistent.

---

## Rationale

| Criteria | Trim the whole catalog to match MVP | Full catalog, full assignment (current default) | Full catalog, all standard assignments disabled (chosen) |
| :--- | :--- | :--- | :--- |
| **Anyone cloning the repo can deploy a full enterprise-scale catalog later** | ❌ Definitions removed, has to be re-added by hand | ✅ | ✅ |
| **`terraform apply` succeeds cleanly today** | ✅ | ❌ 70 role-assignment errors | ✅ |
| **Matches the actual state of the platform (no observability, no network, no MDFC yet)** | ✅ | ❌ | ✅ |
| **Re-enabling a policy is explicit and incremental** | ❌ Requires sourcing the definition JSON again | ❌ N/A | ✅ Remove one line from `locals.tf` |
| **Cost of maintaining disabled assignments** | N/A | N/A | ✅ `creation_enabled = false` has zero Azure cost or effect |

---

## Implementation

The live source of truth is `terraform/stages/1-governance/locals.tf`:

```hcl
# MVP: all standard ALZ policy assignments disabled — re-enable individually as the platform matures.
_mvp_disabled_assignments = merge(
  {
    (local.mg.root) = [
      "Deploy-MCSB2-Monitoring",
      "Deploy-AzActivity-Log",
      "Deploy-ASC-Monitoring",
      ...
    ]
    (local.mg.management) = [...]
    (local.mg.connectivity) = [...]
    (local.mg.corp) = [...]
    (local.mg.landingzones) = [...]
    (local.mg.platform) = [...]
  },
  # optional MGs (identity, sandboxes, decommissioned, local)
  { for mg_key, assignments in {...} : local.mg[mg_key] => assignments
    if contains(keys(local.mg), mg_key) }
)
```

`_disabled_by_mg` converts the list into the `{ creation_enabled = false }` shape expected by the module, then merges it with `var.policy_assignments_to_modify` so operator overrides always take precedence.

---

## Consequences

### Positive

- The repository ships a genuinely complete, enterprise-scale policy catalog — matching the original goal of letting anyone accelerate their own landing zone from it.
- `1-governance` applies cleanly with zero role-assignment errors.
- Re-enabling any policy is a one-line change in `locals.tf` — remove the entry from the relevant list.
- The full list of what is deferred is explicit and auditable in `locals.tf`, not silently absent.

### Negative

- The platform enforces virtually no Azure governance policy at MVP beyond the two custom tag-audit assignments. This must be stated clearly in the README's Project Status table.
- `_mvp_disabled_assignments` is a manual list that must be maintained as the ALZ library evolves (new policies introduced by upstream `avm-ptn-alz` upgrades won't automatically be disabled).

---

## When to reconsider

Re-enable assignments incrementally, in this suggested order, as the platform stages land:

| Stage | Assignments to re-enable |
| :--- | :--- |
| After `2-connectivity` (hub-spoke, DDoS plan) | `Enable-DDoS-VNET`, `Deny-Subnet-Without-Nsg`, `Deny-Public-IP-On-NIC` |
| After `3-observability` (Log Analytics Workspace) | `Deploy-MCSB2-Monitoring`, `Deploy-AzActivity-Log`, `Deploy-ASC-Monitoring`, `Deploy-Diag-LogsCat` — populate `policy_default_values` with real workspace/event-hub IDs |
| After `4-security` (MDFC, Key Vault baseline) | `Deploy-MDFC-Config-H224`, `Deploy-MDEndpoints`, `Enforce-ACSB`, `Enforce-GR-KeyVault` |
| Gradually, per workload type | `Enforce-GR-*` guardrail assignments (AKS, SQL, Storage, etc.) |

To re-enable a policy, remove it from its list in `_mvp_disabled_assignments`, run `terraform plan -out=tfplan`, verify the plan shows only the expected new assignments, then apply.

---

## Alternatives Considered

- **Trim the policy/policy-set definition catalog itself to only what's currently assigned**: Rejected — this defeats the goal of shipping a full enterprise-scale catalog; definitions cost nothing to keep.
- **Keep the default full assignment list as-is and accept the 70 errors**: Rejected — `terraform apply` should not ship with known, reproducible errors.
- **Disable only the diagnostic-settings-dependent policies** (original draft of this ADR): Rejected after a full inventory revealed that most standard ALZ assignments require infrastructure or compliance posture the MVP platform doesn't have yet. A broader disable is cleaner than a piecemeal one.
- **Fabricate placeholder diagnostic destination IDs to satisfy `policy_default_values`**: Rejected — would create role assignments pointing at non-existent resources, silently failing at the Azure API level.

---

## Related ADRs

- [ADR-012](012-avm-pattern-modules.md): the AVM pattern module whose default architecture produced this catalog/assignment split.
- [ADR-010](010-terraform-bootstrap-strategy.md): the bootstrap stage (`0-bootstrap`) that must run before `1-governance`.
- [ADR-004](004-why-private-endpoints.md): the broader cost- and scope-conscious MVP stance this decision stays consistent with.

---

## References

- [Azure Landing Zones policy library (alz-library)](https://github.com/Azure/Azure-Landing-Zones-Library)
- [Azure/avm-ptn-alz (Terraform Registry)](https://registry.terraform.io/modules/Azure/avm-ptn-alz)

---

## Changelog

| Date | Author | Changes |
| :--- | :--- | :--- |
| 2026-07-30 | Mariano Gbego | Initial draft — selective disable of diagnostic-settings policies only |
| 2026-07-30 | Mariano Gbego | Updated to reflect actual implementation: all standard ALZ assignments disabled via `_mvp_disabled_assignments` in `locals.tf`; re-enable roadmap added |

---

*This ADR follows the [Nexus Azure Platform ADR Template](_template.md).*
