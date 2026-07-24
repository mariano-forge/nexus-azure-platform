# ADR-008: Team Structure and Governance Model for Nexus Azure Platform

**Status:** ✅ Accepted  
**Date:** 2026-07-24  
**Author:** Mariano Gbego  
**Context:** Nexus Azure Platform

---

## Context

The Nexus Azure Platform is designed to be adopted by enterprise organizations with multiple teams, each with distinct responsibilities. For the platform to be truly "enterprise-ready," it must embed governance not only in the code but also in the **organizational structure** that manages it.

This ADR defines the **team structure**, **ownership model**, and **governance rules** that will be applied across the project. It establishes:
- Which teams exist and why.
- What each team owns.
- How changes are reviewed and approved.
- How this structure is enforced in the repository (CODEOWNERS, branch protection).

---

## Decision

We will adopt a **multi-team governance model** with four distinct teams, each responsible for a specific domain of the platform.

### Teams and Responsibilities

| Team | Responsibility | Key Resources |
| :--- | :--- | :--- |
| **`@mariano-forge/governance`** | Cloud Governance | Management Groups, Azure Policies, RBAC at root level, compliance |
| **`@mariano-forge/network`** | Networking | Hub & Spoke VNets, Peering, Private DNS, NSGs, Azure Firewall |
| **`@mariano-forge/security`** | Security & Compliance | Key Vault, Defender for Cloud, PIM, RBAC, secrets rotation |
| **`@mariano-forge/platform-engineering`** | Platform & Developer Experience | AKS, Backstage, Observability, GitOps (ArgoCD), CI/CD pipelines |

### Ownership Rules

1. **Each team is the primary owner** of its domain.
2. **Changes to a domain require approval** from the corresponding team.
3. **Critical files** (README, ADRs, workflows, CI/CD) require **approval from all teams**.
4. **Production environments** require **approval from all teams** before deployment.

---

## Rationale

### Why Multi-Team Governance?

| Criteria | Multi-Team Model | Single-Team Model |
| :--- | :--- | :--- |
| **Separation of Duties** | ✅ Enforced | ❌ Single team has full control |
| **Audit Trail** | ✅ Clear ownership, easier to trace changes | ⚠️ Blurred lines of responsibility |
| **Organizational Alignment** | ✅ Matches common enterprise structures (SecOps, NetOps, Platform) | ❌ Forces companies to reorganize |
| **Risk Mitigation** | ✅ Reduces risk of misconfiguration | ❌ Single point of failure |
| **Adoption** | ✅ Companies can adopt the model as-is | ❌ Requires adaptation |

### Why These Four Teams?

The four teams map directly to **common enterprise functions**:

| Team | Why It Exists |
| :--- | :--- |
| **Governance** | Defines the "rules of the game" — what is allowed, what is denied, and how resources are organized. |
| **Network** | Owns connectivity. Without network, nothing works. This team ensures traffic flows securely. |
| **Security** | Owns the "keys to the kingdom" — secrets, policies, and compliance. |
| **Platform Engineering** | Owns the developer experience and the runtime environment (Kubernetes, GitOps, observability). |

> **Note:** The separation between Network and Security enforces **separation of duties** — a fundamental security principle required for compliance (e.g., PCI-DSS, SOC2, ISO 27001).

---

## Implementation

### 1. GitHub Teams

Teams will be created in the `mariano-forge` organization and granted appropriate permissions on the repository:

| Team | Permission | Why |
| :--- | :--- | :--- |
| `governance` | Write (on their domain) | Can merge changes to governance files |
| `network` | Write (on their domain) | Can merge changes to networking files |
| `security` | Write (on their domain) | Can merge changes to security files |
| `platform-engineering` | Write (on their domain) | Can merge changes to platform files |

All teams have **read** access to the entire repository. **Write** access is restricted to their respective domains via `CODEOWNERS`.

### 2. CODEOWNERS Enforcement

The `.github/CODEOWNERS` file enforces ownership at the file/directory level:

```text
# Default owners — catch-all
**/* @mariano-forge/platform-engineering

# Governance
/terraform/modules/landing-zone/ @mariano-forge/governance
/terraform/modules/policies/ @mariano-forge/governance

# Network
/terraform/modules/networking/ @mariano-forge/network
/terraform/modules/dns/ @mariano-forge/network

# Security
/terraform/modules/security/ @mariano-forge/security
/terraform/modules/keyvault/ @mariano-forge/security

# Platform
/terraform/modules/aks/ @mariano-forge/platform-engineering
/terraform/modules/backstage/ @mariano-forge/platform-engineering
/terraform/modules/observability/ @mariano-forge/platform-engineering

# Critical files (require all teams)
/.github/ @mariano-forge/governance @mariano-forge/network @mariano-forge/security @mariano-forge/platform-engineering
/docs/adr/ @mariano-forge/governance @mariano-forge/network @mariano-forge/security @mariano-forge/platform-engineering
/README.md @mariano-forge/governance @mariano-forge/network @mariano-forge/security @mariano-forge/platform-engineering
```

### 3. Branch Protection Rules

The `main` branch is protected with the following rules:

- ✅ Require pull request reviews (at least 1 reviewer).
- ✅ Require code owner reviews (enforced by CODEOWNERS).
- ✅ Require status checks to pass (CI must be green).
- ✅ Include administrators (even admins must follow the rules).

### 4. Environment Protection (Production)

The production environment requires approval from all teams before deployment:

- ✅ Required reviewers: `governance`, `network`, `security`, `platform-engineering`.
- ✅ Wait timer: 5 minutes.

### 5. External Contributors

External contributors are not members of any team. Their PRs follow the standard CODEOWNERS flow — the relevant team receives a review request automatically and approves or requests changes. External contributors do not need a GitHub organization account; they can fork and submit PRs freely.

---

## Consequences

### Positive
- **Clear ownership**: Every team knows exactly what they are responsible for.
- **Stronger security posture**: Changes to critical infrastructure require multiple approvals.
- **Adoption-friendly**: Companies with existing teams (SecOps, NetOps, Platform) can adopt the platform as-is.
- **Compliance-ready**: Separation of duties aligns with PCI-DSS, SOC2, and ISO 27001 requirements.

### Negative
- **Slightly more friction**: Some PRs may require reviews from multiple teams, slowing down velocity.
- **Increased complexity**: The CODEOWNERS file becomes more granular and requires careful maintenance.
- **Initial setup overhead**: Creating teams and configuring permissions takes time.

### Mitigation
- For non-critical changes, the default owner (`@mariano-forge/platform-engineering`) can review and approve.
- Use GitHub's CODEOWNERS feature to enforce reviews only on relevant paths.
- Document the ownership model clearly in `CONTRIBUTING.md`.

---

## When to Reconsider

This decision should be revisited if:

- **The platform scales beyond four teams** — if new domains emerge (e.g., Data Engineering, FinOps), new teams may be required.
- **The organization adopts a different governance model** — if the company standardizes on a different structure.
- **GitHub introduces new governance features** — we should adopt them if they improve the workflow.

---

## Alternatives Considered

1. **Single-team model**  
   - *Why rejected?* No separation of duties, single point of failure, and not aligned with enterprise governance requirements.

2. **Per-environment teams (dev/staging/prod)**  
   - *Why rejected?* Environment-based ownership creates silos and doesn't reflect how platform teams actually work. Domain-based ownership is more durable.

3. **External governance tools (OPA, Sentinel)**  
   - *Why rejected?* Adds complexity for a governance problem that GitHub's native CODEOWNERS + branch protection already solves cleanly at this scale.

---

## Related ADRs

- [ADR-007 (planned)](007-why-network-security-split.md) : Will provide detailed justification for splitting Network and Security into separate teams.
- [ADR-002](002-why-hub-spoke.md) : Network team owns the Hub & Spoke topology.
- [ADR-004](004-why-private-endpoints.md) : Security team owns Key Vault and Private Endpoints.
- [ADR-003](003-why-github-actions.md) : Platform Engineering team owns the CI/CD pipelines.

---

## References

- [GitHub CODEOWNERS Documentation](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [NIST SP 800-53 — Separation of Duties (AC-5)](https://csrc.nist.gov/Projects/risk-management/sp800-53-controls/release-search#!/control?version=5.1&number=AC-5)
- [PCI-DSS v4.0 — Requirement 6](https://www.pcisecuritystandards.org/document_library/)

---

## Changelog

| Date | Author | Changes |
| :--- | :--- | :--- |
| 2026-07-24 | Mariano Gbego | Initial draft |

---

*This ADR follows the [Nexus Azure Platform ADR Template](_template.md).*
