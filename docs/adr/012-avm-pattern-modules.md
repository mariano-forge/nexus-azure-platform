# ADR-012: AVM Pattern Modules for Governance and Subscription Vending

**Status:** ✅ Accepted  
**Date:** 2026-07-25
**Author:** Mariano Gbego  
**Context:** Nexus Azure Platform

---

## Context

Stage `0-governance` needs to create a management group hierarchy with policy assignments/definitions, and stage `5-workloads` needs to provision real Azure subscriptions on demand through the Backstage self-service portal (see [ADR-005](005-why-backstage.md)).

Both could be hand-written in Terraform directly against `azurerm`/`azapi` resources. However, Microsoft publishes and maintains **Azure Verified Modules (AVM)** — including two **pattern modules** purpose-built for exactly these two problems:

- `Azure/avm-ptn-alz/azurerm` — management group hierarchy and policy assignment/definition management.
- `Azure/avm-ptn-alz-sub-vending/azure` — subscription creation, management group association, resource provider registration, RBAC assignment, and budget enforcement in a single module.

The billing account backing this project is a **Microsoft Customer Agreement (MCA)**, which is a supported billing scope for `avm-ptn-alz-sub-vending`.

---

## Decision

We will use the AVM **pattern** modules `avm-ptn-alz` and `avm-ptn-alz-sub-vending` directly, wrapped with a pinned version (see [ADR-011](011-dependency-management-strategy.md)), instead of writing the governance and subscription-vending logic by hand.

Resource-level concerns not covered by these pattern modules — networking (Hub & Spoke) and Key Vault — remain hand-wrapped around AVM **resource** modules (`avm-res-network-virtualnetwork`, `avm-res-keyvault-vault`), as already scoped for stages `1-connectivity` and `2-security`.

---

## Rationale

| Criteria | Hand-written Terraform | AVM pattern modules (`avm-ptn-alz`, `avm-ptn-alz-sub-vending`) |
| :--- | :--- | :--- |
| **Correctness of MG hierarchy / policy semantics** | ⚠️ Easy to get subtle Azure Policy scoping wrong | ✅ Maintained by Microsoft, tested against real ALZ scenarios |
| **Subscription vending budget enforcement** | ❌ Would need to be built and tested from scratch | ✅ Built in natively — matches the M2 decision that budgets are created alongside the subscription |
| **Maintenance burden for a solo maintainer** | ❌ Every Azure API change is the maintainer's problem | ✅ Upstream maintainers absorb most breaking-change churn; tracked via Dependabot |
| **Credibility / recognizability** | ⚠️ A reviewer has to trust untested custom code | ✅ Reviewer recognizes a well-known, Microsoft-supported pattern |
| **Flexibility for non-standard requirements** | ✅ Full control | ⚠️ Constrained to the module's exposed variables — acceptable here since our requirements match the standard ALZ pattern |

---

## Consequences

### Positive

- Significantly less custom Terraform to write, review, and maintain for governance and subscription vending.
- Budget-per-subscription (a requirement from M2) comes for free from `avm-ptn-alz-sub-vending`, with no custom `azurerm_consumption_budget` logic to test.
- Aligns the project with the approach Microsoft itself documents for enterprise-scale landing zones — a stronger signal of correctness than an independently written equivalent.

### Negative

- Adds a dependency on two more upstream modules whose release cadence isn't controlled by this project — mitigated by the pinned-version + Dependabot strategy already in place (ADR-011).
- `avm-ptn-alz` covers governance only — it does **not** replace the need for hand-wrapped resource modules for networking and Key Vault; this must stay clear in the module documentation to avoid the false impression that "using AVM" means everything is pattern-module-driven.
- `avm-ptn-alz-sub-vending` requires a real MCA billing scope; this decision is a dead end if the billing account type ever changes to something the module doesn't support.

---

## When to reconsider

- If a requirement emerges that the pattern modules' exposed variables cannot express (e.g., a non-standard policy assignment shape) — at that point, a hand-written override or a fork would need to be evaluated.
- If Microsoft deprecates or stops maintaining either module in favor of a successor (as already happened once: `Azure/lz-vending/azurerm` → `Azure/avm-ptn-alz-sub-vending/azure`).

---

## Alternatives Considered

- **Fully hand-written Terraform for governance and subscription vending**: Rejected — duplicates effort already solved and tested by Microsoft, and shifts all future Azure API churn onto a solo maintainer.
- **`Azure/lz-vending/azurerm` (the module's predecessor name)**: Rejected — superseded by `avm-ptn-alz-sub-vending` under the current AVM naming convention; using the deprecated name would mean adopting a module already on a migration path.

---

## Related ADRs

- [ADR-001](001-why-terraform.md): establishes Terraform as the IaC tool this decision operates within.
- [ADR-005](005-why-backstage.md): the self-service portal that triggers `avm-ptn-alz-sub-vending` on demand.
- [ADR-009](009-key-vault-separation.md): the Key Vault split that stays hand-wrapped, since it falls outside this decision's scope.
- [ADR-011](011-dependency-management-strategy.md): the version-pinning and Dependabot strategy applied to these two modules.

---

## References

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Azure/avm-ptn-alz (Terraform Registry)](https://registry.terraform.io/modules/Azure/avm-ptn-alz)
- [Azure/avm-ptn-alz-sub-vending (Terraform Registry)](https://registry.terraform.io/modules/Azure/avm-ptn-alz-sub-vending/azure/latest)
- [Subscription vending — Cloud Adoption Framework](https://learn.microsoft.com/azure/architecture/landing-zones/subscription-vending)

---

## Changelog

| Date | Author | Changes |
| :--- | :--- | :--- |
| 2026-07-25 | Mariano Gbego | Initial draft |

---

*This ADR follows the [Nexus Azure Platform ADR Template](_template.md).*
