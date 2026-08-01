# ADR-007: Separation of Duties — Network vs Security Teams

**Status:** ✅ Accepted  
**Date:** 2026-07-24  
**Author:** Mariano Gbego  
**Context:** Nexus Azure Platform

---

## Context

The Nexus Azure Platform is designed to be adopted by enterprise organizations with multiple teams. As the platform matures, governance and security controls must be embedded not only in the code but also in the **organizational structure** that manages it.

Currently, both networking (Hub & Spoke, Private DNS, NSGs) and security (Key Vault, Azure Policies, RBAC, Defender) components are defined in the codebase. In many organizations, these are owned by separate teams to enforce **separation of duties** — a fundamental security principle.

The question is: **Should we model this separation explicitly in the project's governance (CODEOWNERS, team structure), or keep them under a single umbrella?**

---

## Decision

We will **separate** networking and security into two distinct teams with independent ownership and approval requirements:

- **`@mariano-forge/network`** : Owns all networking resources (VNets, peering, Private DNS, NSGs, Azure Firewall, route tables).
- **`@mariano-forge/security`** : Owns all security resources (Key Vault, Azure Policies, RBAC, PIM, Defender for Cloud, compliance).

---

## Rationale

| Criteria | Separate Teams | Combined Team |
| :--- | :--- | :--- |
| **Separation of Duties** | ✅ Enforced | ❌ Single team can create network holes and approve them |
| **Audit Trail** | ✅ Clear ownership, easier to audit changes | ⚠️ Blurred lines of responsibility |
| **Organizational Alignment** | ✅ Matches common enterprise structure (SecOps vs NetOps) | ❌ Forces companies to reorganize to adopt the platform |
| **Risk Mitigation** | ✅ Reduces risk of misconfiguration (two pairs of eyes) | ❌ Single point of failure |
| **Complexity** | ⚠️ Slightly more complex approval process | ✅ Simpler (one team) |

**Why this is important for an enterprise platform:**

In a regulated environment (finance, healthcare, government), **separation of duties** is often a compliance requirement (e.g., PCI-DSS, SOC2). A single team that can both create a network vulnerability and approve its deployment represents a significant risk.

By modelling this separation explicitly, the platform demonstrates:

- **Security awareness** — we don't just talk about security, we embed it.
- **Enterprise readiness** — organizations can adopt the platform without restructuring.
- **Maturity** — we think beyond the code to the people and processes.

---

## Consequences

### Positive

- **Clear ownership**: Each team knows exactly what they are responsible for.
- **Stronger security posture**: Changes to critical infrastructure require multiple approvals.
- **Adoption-friendly**: Companies with separate NetOps and SecOps teams can adopt the platform as-is.

### Negative

- **Slightly more friction**: Some PRs may require reviews from two teams, slowing down velocity.
- **Increased complexity**: The CODEOWNERS file becomes more granular and requires careful maintenance.

### Mitigation

- For non-critical changes, the default owner (`@mariano-forge/platform-engineering`) can review and approve.
- Use GitHub's **CODEOWNERS** feature to enforce reviews only on relevant paths.
- Document the ownership model clearly in `CONTRIBUTING.md`.

---

## When to Reconsider

This decision should be revisited if:

- **The organization merges NetOps and SecOps** — some smaller organizations operate with a single Infrastructure & Security team. The platform should document how to adapt the CODEOWNERS accordingly.
- **A new compliance framework requires a different split** — e.g., separating identity (RBAC/PIM) from secrets (Key Vault) into a dedicated Identity team.
- **The complexity of dual-approval becomes a bottleneck** — if PR cycle times increase significantly, consider a tiered approval model.

---

## Implementation

This decision is implemented in the `.github/CODEOWNERS` file:

```text
# Network team owns networking resources
/terraform/modules/networking/ @mariano-forge/network
/terraform/modules/dns/        @mariano-forge/network

# Security team owns security resources
/terraform/modules/security/   @mariano-forge/security
/terraform/modules/keyvault/   @mariano-forge/security
/terraform/modules/defender/   @mariano-forge/security
/terraform/modules/rbac/       @mariano-forge/security

# Critical files require approval from all teams
/.github/  @mariano-forge/governance @mariano-forge/network @mariano-forge/security @mariano-forge/platform-engineering
/docs/adr/ @mariano-forge/governance @mariano-forge/network @mariano-forge/security @mariano-forge/platform-engineering
/README.md @mariano-forge/governance @mariano-forge/network @mariano-forge/security @mariano-forge/platform-engineering
```

---

## Alternatives Considered

1. **Combine Network and Security into a single team**  
   - *Why rejected?* Violates separation of duties principle, makes auditing harder, and may not align with enterprise structures.

2. **Keep a single team but require two individual reviewers**  
   - *Why rejected?* Still gives power to a single team. The organizational structure must reflect the security boundaries — individual reviewers within one team can collude or be pressured.

3. **Split further into Identity, Secrets, and Network sub-teams**  
   - *Why rejected?* Over-engineering for the current scale. Can be revisited when the platform grows beyond four core domains.

---

## Related ADRs

- [ADR-001](001-why-terraform.md) : Both teams will use Terraform modules for their respective resources.
- [ADR-002](002-why-hub-spoke.md) : Network team will own the Hub & Spoke topology.
- [ADR-004](004-why-private-endpoints.md) : Security team will own the Key Vault and Private Endpoints strategy.
- [ADR-008](008-team-structure-governance.md) : Defines the full multi-team governance model that this ADR feeds into.

---

## References

- [GitHub CODEOWNERS Documentation](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [NIST SP 800-53 — Separation of Duties (AC-5)](https://csrc.nist.gov/Projects/risk-management/sp800-53-controls/release-search#!/control?version=5.1&number=AC-5)
- [PCI-DSS v4.0 — Requirement 6](https://www.pcisecuritystandards.org/document_library/)

---

## Changelog

| Date | Author | Changes |
| :--- | :--- | :--- |
| 2026-07-24 | Mariano Gbego | Initial draft |

---

*This ADR follows the [Nexus Azure Platform ADR Template](_template.md).*
