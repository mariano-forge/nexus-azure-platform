# Architecture Decision Records (ADR)

This directory contains the Architecture Decision Records for the Nexus Azure Platform.

## What is an ADR?

An ADR documents a significant architectural decision that has been made for the project. It captures:

- **Context** : Why a decision was needed.
- **Decision** : What was decided.
- **Rationale** : Why this decision was made over alternatives.
- **Consequences** : What trade-offs or impacts come with this decision.

## ADR List

| ADR | Decision | Status |
| --- | --- | --- |
| [ADR-001](001-why-terraform.md) | Why Terraform over Bicep/Pulumi? | ✅ Accepted |
| [ADR-002](002-why-hub-spoke.md) | Why Hub & Spoke topology? | ✅ Accepted |
| [ADR-003](003-why-github-actions.md) | Why GitHub Actions over Azure DevOps? | ✅ Accepted |
| [ADR-004](004-why-private-endpoints.md) | Why Private Endpoints and no Azure Firewall? | ✅ Accepted |
| [ADR-005](005-why-backstage.md) | Why Backstage for the IDP? | 🚧 Draft |
| [ADR-006](006-why-argocd.md) | Why ArgoCD for GitOps? | 💡 Future — not in current roadmap |
| [ADR-007](007-separation-network-security.md) | Separation of Duties — Network vs Security | ✅ Accepted |
| [ADR-008](008-team-structure-governance.md) | Team Structure and Governance Model | ✅ Accepted |
| [ADR-009](009-key-vault-separation.md) | Key Vault Separation — pipeline vs app secrets | ✅ Accepted |
| [ADR-010](010-terraform-bootstrap-strategy.md) | Terraform Bootstrap Strategy | ✅ Accepted |
| [ADR-011](011-dependency-management-strategy.md) | Dependency Management — AVM pinning + Dependabot | ✅ Accepted |

## How to create a new ADR

1. Copy the [template](_template.md) and name it `NNN-short-description.md`.
2. Fill in all sections, replacing the example content.
3. Update this `index.md` with the new entry.
4. Link the ADR in the README table.

## Contributing

When contributing a significant architectural change, please create an ADR to document the decision process.

---

*Last updated: 2026-07-29*