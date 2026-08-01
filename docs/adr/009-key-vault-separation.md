# ADR-009: Key Vault Separation — Platform/Pipeline Secrets vs Backstage App Secrets

**Status:** ✅ Accepted  
**Date:** 2026-07-25  
**Author:** Mariano Gbego  
**Context:** Nexus Azure Platform

---

## Context

Stage `2-security` (M1) provisions a Key Vault to hold platform-level secrets: the Terraform backend access, GitHub tokens used by the pipeline. Stage `4-platform` (M2) introduces Backstage, which itself needs secrets — the PostgreSQL connection string, GitHub App/OAuth credentials for authentication.

The question is whether Backstage should read from the same Key Vault as the pipeline, or from a dedicated one.

- If Backstage's Managed Identity is granted read access to the platform Key Vault, it technically *can* read the pipeline's secrets too unless permissions are scoped precisely.
- The platform already applies a least-privilege principle via RBAC/PIM (ADR-007, separation of duties between network and security teams) — secrets should follow the same logic.

---

## Decision

We will use **two separate Key Vaults**:

- `kv-platform-pipeline` (stage `2-security`) — holds Terraform backend secrets, GitHub tokens used by CI/CD.
- `kv-backstage-app` (stage `4-platform`) — holds Backstage's own secrets (Postgres connection string, GitHub App credentials).

Each vault has its own Managed Identity scope: the pipeline's identity has no access to `kv-backstage-app`, and Backstage's identity has no access to `kv-platform-pipeline`.

---

## Rationale

| Criteria | Single vault, vault-level RBAC | Single vault, secret-level RBAC | Two separate vaults |
| :--- | :--- | :--- | :--- |
| **Blast radius if one identity is compromised** | ❌ Full access to all secrets | ⚠️ Scoped, but relies on getting every assignment right | ✅ Naturally contained to one domain |
| **Simplicity to reason about** | ✅ One vault to track | ❌ Requires auditing per-secret RBAC continuously | ✅ Ownership is obvious from the vault name |
| **Cost** | ✅ Slightly cheaper (one vault) | ✅ Same | ⚠️ Marginal extra cost (Key Vault pricing is per-operation, not per-vault, so this is negligible) |
| **Consistency with existing separation-of-duties pattern (ADR-007)** | ❌ Contradicts it | ⚠️ Partially aligns | ✅ Directly extends it to secrets |

---

## Consequences

### Positive

- Compromise of the Backstage App Service (a more exposed, developer-facing component) cannot expose pipeline/backend secrets.
- Ownership is unambiguous: the vault name tells you which team/system owns what's inside.
- No dependency on remembering to scope every individual secret's RBAC correctly — the boundary is the vault itself.

### Negative

- Slightly more Terraform to maintain (two vault resources instead of one).
- Two places to check when auditing "what secrets exist" — mitigated by listing both vaults in the observability/runbook documentation.

---

## When to reconsider

- If the platform grows to the point where dozens of workloads each need their own scoped secrets — at that point, per-workload Key Vaults (one per app, created via the `subscription-vending`/`keyvault` module) become more relevant than a two-vault split at the platform level.
- If Azure Key Vault Managed HSM becomes a requirement for compliance reasons, which would likely reshape this decision entirely.

---

## Alternatives Considered

- **Single vault, vault-level RBAC only**: Rejected — grants broad access by default; contradicts the least-privilege principle already established in ADR-007.
- **Single vault, secret-level RBAC**: Rejected for now — technically possible, but requires disciplined, continuously-audited per-secret role assignments; more fragile than a hard boundary between vaults, especially for a solo-maintained project.

---

## Related ADRs

- [ADR-007](007-separation-network-security.md): establishes the separation-of-duties principle this decision extends to secrets.
- [ADR-005](005-why-backstage.md): introduces Backstage as the component that needs its own secret scope.

---

## References

- [Azure Key Vault RBAC vs access policies](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide)

---

## Changelog

| Date | Author | Changes |
| :--- | :--- | :--- |
| 2026-07-25 | Mariano Gbego | Initial draft |

---

*This ADR follows the [Nexus Azure Platform ADR Template](_template.md).*
