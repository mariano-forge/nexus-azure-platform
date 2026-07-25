# ADR-010: Terraform Bootstrap Strategy

**Status:** ✅ Accepted  
**Date:** 2026-07-25  
**Author:** Mariano Gbego  
**Context:** Nexus Azure Platform

---

## Context

Every stage (`0-governance` onward) uses a remote Terraform backend (Azure Storage Account + Container) for state, and stage `2-security` provisions the platform Key Vault referenced by later stages and by CI.

This creates a chicken-and-egg problem: the storage account and initial Key Vault cannot be created by a Terraform run that itself needs a remote backend and Key Vault access to authenticate and store its own state. Something has to exist before the "real" IaC can run.

---

## Decision

We will use a **minimal, one-time bootstrap step**, run manually (or via a dedicated, rarely-run GitHub Actions workflow) with **local state**, whose only job is to create:
- The Storage Account + Container that will host the remote backend for every other stage.
- The initial Key Vault (`kv-platform-pipeline`, see [ADR-009](009-key-vault-separation.md)) used to store the credentials the pipeline needs going forward.

The bootstrap's own state file is kept local (not remote) and is treated as a rarely-touched, manually-reviewed piece of infrastructure — it is not expected to change often once the platform exists.

---

## Rationale

| Criteria | Manual Azure CLI script | Bootstrap Terraform (local state) | Managed backend service (Terraform Cloud) |
| :--- | :--- | :--- | :--- |
| **Reproducibility** | ❌ Imperative, easy to drift | ✅ Declarative, versioned in Git | ✅ Declarative |
| **Extra service/cost** | ✅ None | ✅ None | ❌ New external dependency for a one-person project |
| **Consistency with the rest of the stack (all Terraform)** | ❌ Breaks the "everything is Terraform" story | ✅ Stays in Terraform, just with a different state location | ✅ Also Terraform, but a different backend model |
| **Solo-maintainer overhead** | ⚠️ Low effort but easy to forget/undocument | ✅ Low effort, one extra folder | ❌ Another account/service to manage |

---

## Consequences

### Positive
- The entire platform, including its own foundation, is expressed in Terraform — no undocumented manual `az` commands.
- The bootstrap folder is small, isolated, and clearly marked as "run once, rarely touched again" in its own README.

### Negative
- The bootstrap state is local, meaning it isn't automatically backed up the way remote state is — this is mitigated by committing the bootstrap output values (resource IDs) to documentation immediately after running it, and by the fact that this step recreates cheap, non-critical resources if ever lost.
- Anyone reproducing this project from scratch needs to know to run the bootstrap step first — documented explicitly in the README's "Getting Started" section, before the per-stage `terraform init`.

---

## When to reconsider

- If this project is ever adopted by an organization with an existing shared bootstrap/landing-zone-factory pattern (e.g., a central platform team already manages backend provisioning) — in that case, this project's stages would consume an existing backend instead of bootstrapping their own.
- If the local bootstrap state is ever lost and recreating it becomes disruptive — at that point, moving the bootstrap state itself to a very minimal remote backend (e.g., a single storage account managed outside Terraform) would be reconsidered.

---

## Alternatives Considered

- **Fully manual Azure CLI script**: Rejected — no declarative trace of what was created, harder to review, and breaks the "everything is IaC" principle applied everywhere else in this project.
- **Terraform Cloud / remote managed backend from day one**: Rejected — introduces an external service and account dependency for what is, at this stage, a single-maintainer project already using Azure Storage as a backend for every other stage.
- **GitHub Actions workflow that provisions the backend using OIDC before any state exists**: Rejected — this only moves the chicken-and-egg problem into a workflow; the underlying storage account still needs to exist before Terraform can use it as a backend.

---

## Related ADRs

- [ADR-009](009-key-vault-separation.md): the bootstrap step creates the platform Key Vault this ADR defines the scope of.
- [ADR-001](001-why-terraform.md): establishes Terraform as the IaC tool this bootstrap approach stays consistent with.

---

## References

- [Terraform backend documentation](https://developer.hashicorp.com/terraform/language/settings/backends/configuration)

---

## Changelog

| Date | Author | Changes |
| :--- | :--- | :--- |
| 2026-07-25 | Mariano Gbego | Initial draft |

---

*This ADR follows the [Nexus Azure Platform ADR Template](_template.md).*
