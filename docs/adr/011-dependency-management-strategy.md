# ADR-011: Dependency Management Strategy — AVM Version Pinning + Dependabot

**Status:** ✅ Accepted  
**Date:** 2026-07-25  
**Author:** Mariano Gbego  
**Context:** Nexus Azure Platform

---

## Context

Reusable modules in this project are wrapped **Azure Verified Modules (AVM)**, with every version pinned explicitly rather than left floating. Pinning protects against unreviewed breaking changes landing silently, but it also means versions will quietly go stale unless something surfaces new releases for review.

As a solo-maintained project, any solution needs to require close to zero ongoing operational overhead — no server or scheduled job to keep running, no extra account to manage.

---

## Decision

We will use **Dependabot**, native to GitHub, configured via a single `.github/dependabot.yml` file to track Terraform (AVM modules, providers) and GitHub Actions versions on a weekly schedule. Dependabot opens a PR for each available update; the existing `pr-validation.yml` pipeline (`terraform plan`, tfsec, Checkov) runs on it like any other PR, followed by manual review and merge.

---

## Rationale

| Criteria | Manual tracking | Renovate | Dependabot |
| :--- | :--- | :--- | :--- |
| **Operational overhead** | ⚠️ Zero infra, but relies on remembering to check | ⚠️ More configuration surface (grouping rules, scheduling) | ✅ Single YAML file, hosted by GitHub |
| **No server/scheduled job to maintain** | ✅ | ✅ (runs via GitHub Action or hosted app) | ✅ (fully native, no action needed) |
| **Setup complexity for a single, targeted use case (Terraform + Actions)** | ✅ Trivial (nothing to set up) | ❌ More knobs than needed here | ✅ Minimal — exactly what's needed |
| **Integrates with existing PR pipeline without extra work** | N/A | ✅ | ✅ |
| **Security-update PRs for known CVEs** | ❌ None | ✅ (if configured) | ✅ (native "Dependabot security updates") |

---

## Consequences

### Positive
- Zero infrastructure to run or monitor — Dependabot executes entirely on GitHub's side.
- Every version bump goes through the same review/approval path as any other change (PR + `pr-validation.yml` + manual merge), so no new process was introduced.
- Security-update PRs are available natively, independent of the weekly schedule.

### Negative
- Dependabot does not run functional or smoke tests of its own — a version bump is only validated by `terraform plan` plus manual review, not by an actual deployment. This is an accepted limitation for now (see [ADR-010](010-terraform-bootstrap-strategy.md) for the broader dry-run-first validation approach used across this project).
- Less configurable than Renovate for advanced scenarios (grouping multiple updates into one PR, custom scheduling per package) — acceptable given the small number of dependencies actually tracked here.

---

## When to reconsider

- If the number of tracked dependencies grows large enough that PR volume from Dependabot becomes noisy (e.g., many AVM modules each bumping independently) — Renovate's grouping rules would then justify the extra configuration effort.
- If a real Sandbox environment is stood up permanently, making an automated post-merge smoke test feasible — at that point, this ADR would be revisited alongside a decision on automated deployment validation.

---

## Alternatives Considered

- **Manual tracking**: Rejected — relies on remembering to check for updates; pinned versions would silently go stale.
- **Renovate**: Rejected for now — more powerful (grouping, fine-grained scheduling), but that flexibility isn't needed for tracking a handful of Terraform/AVM/Actions dependencies on a solo project; the added configuration surface isn't worth it at this scale.

---

## Related ADRs

- [ADR-001](001-why-terraform.md): establishes Terraform as the IaC tool whose module versions this ADR governs.
- [ADR-010](010-terraform-bootstrap-strategy.md): the broader dry-run-first validation approach this ADR's testing limitation is consistent with.

---

## References

- [Dependabot documentation — GitHub Docs](https://docs.github.com/en/code-security/dependabot)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)

---

## Changelog

| Date | Author | Changes |
| :--- | :--- | :--- |
| 2026-07-25 | Mariano Gbego | Initial draft |

---

*This ADR follows the [Nexus Azure Platform ADR Template](_template.md).*
