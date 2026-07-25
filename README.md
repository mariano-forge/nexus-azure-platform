# Nexus Azure Platform

<!--
  Nexus Azure Platform - Enterprise Internal Developer Platform Blueprint
  Copyright 2026 Mariano Gbego
  Licensed under Apache 2.0
-->

<div align="center">

**A reference implementation of a secure, self-service Azure Landing Zone — with every architectural decision documented and justified.**

*Small in scope. Honest about status. Secured by design.*

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Cloud-Azure-0078D4)](https://azure.microsoft.com)
[![Backstage](https://img.shields.io/badge/IDP-Backstage-9B59B6)](https://backstage.io/)
[![Status](https://img.shields.io/badge/Status-Early%20Stage-orange.svg)]()

</div>

---

## Project status (read this first)

This repository is **early stage**. Nothing here should be assumed to run out of the box yet.

| Component | Status |
| --- | --- |
| Landing Zone Terraform modules (governance, networking, security, observability) | 🚧 Not yet implemented — ADRs and design done, code in progress |
| DevSecOps validation pipeline | ✅ Implemented ([`pr-validation.yml`](.github/workflows/pr-validation.yml)) |
| Backstage self-service portal (subscription + VNet vending) | 📅 Planned, not started |
| Observability dashboard + one real auto-remediation runbook | 📅 Planned, not started |

The **"Quick Start"** section below describes the target workflow once M1 lands — it is marked accordingly and will be updated to "verified working" once the Terraform modules are actually merged and tested against a real subscription.

---

## What is Nexus Azure Platform?

Nexus Azure Platform is a reference implementation of the core building blocks of an enterprise Azure Landing Zone with a developer self-service layer on top.

It answers a narrow, concrete question:

> *What does a governed, secure Azure Landing Zone look like when developers can provision subscriptions and networks themselves, without opening a ticket — and how do you document every trade-off along the way?*

This project intentionally does **not** try to be a full internal developer platform out of the gate. It focuses on getting two things right first:
1. A landing zone that is actually deployed and actually secured.
2. A self-service portal that actually provisions real resources through a real approval workflow.

Everything else — GitOps, a FinOps dashboard plugin, an AI assistant — is documented as a **future direction**, not a current deliverable (see [Beyond this repo](#beyond-this-repo)).

---

## Why this project?

Most cloud infrastructure projects show **what** to deploy. This one also documents **why** each decision was made — including the trade-offs and what would change the decision later.

> 💡 **Why no Azure Firewall in the MVP?**
> To keep the blueprint cost-optimized, this MVP uses NSGs with Service Tags and Private Endpoints for network security — saving roughly 800€/month versus a hub firewall. See [ADR-004](docs/adr/004-why-private-endpoints.md) for the full trade-off and when to reconsider it.

---

## Architecture Overview

```text
┌───────────────────────────────────────────────────┐
│                Nexus Azure Platform                │
│                                                     │
│   ┌─────────────┐        ┌──────────────────┐      │
│   │  Landing    │──────▶ │ Developer         │      │
│   │  Zone       │        │ Self-Service      │      │
│   │  (Terraform)│        │ (Backstage)       │      │
│   └─────────────┘        └──────────────────┘      │
│         │                        │                 │
│         ▼                        ▼                 │
│   ┌─────────────┐        ┌──────────────────┐      │
│   │  Security   │        │  Basic            │      │
│   │  by Design  │        │  Observability    │      │
│   └─────────────┘        └──────────────────┘      │
└───────────────────────────────────────────────────┘
```

> C4 diagrams will be added under `docs/architecture/` as modules are implemented.

---

## Roadmap & Milestones

| # | Milestone | Status | Description |
| --- | --- | --- | --- |
| **M1** 🏗️ | **Landing Zone & Core Security** | 🚧 In Progress | Terraform for Hub/Spoke networking, Private DNS, Private Endpoints, Key Vault, Log Analytics, Azure Policies (deny mode), RBAC. DevSecOps pipeline (tfsec, Checkov, Trivy, Gitleaks, manual approval). |
| **M2** 🧩 | **Developer Self-Service** | 📅 Planned | Backstage portal + Postgres, scaffolder templates for subscription vending and VNet vending only, PR-based approval via CODEOWNERS, MkDocs site. |
| **M3 (partial)** ⚙️ | **Basic Observability** | 📅 Planned | Platform health dashboard (Grafana/Workbooks) and one real, tested auto-remediation runbook (auto-restart) with a dry-run-first safety pattern. |

This is the actual, current commitment. Anything beyond M3 is tracked separately — see below.

---

## Beyond this repo (design only, not implemented)

These are documented as ADRs / design exercises to show the reasoning behind a larger platform vision, without claiming they're built:

- **GitOps** (ArgoCD) — see [ADR-006](docs/adr/006-why-argocd.md)
- **FinOps dashboard integrated into Backstage**
- **AI assistant** (RAG over ADRs, pipeline failure analysis) — any future version of this would enforce suggestion-only behavior (no auto-execution) and PII/secret scrubbing before any data reaches an LLM
- **Full observability stack** (Prometheus/Loki/OTel) beyond the M3 basics

If one of these gets built for real, it moves up into the Roadmap table above with a working demo — not before.

---

## What's inside (current state)

```text
nexus-azure-platform/
├── .github/
│   ├── workflows/
│   │   └── pr-validation.yml   # tflint, fmt/validate, tfsec, Checkov, Trivy, Gitleaks — implemented
│   ├── CODEOWNERS
│   └── CONTRIBUTING.md
├── docs/
│   └── adr/                    # 8 ADRs, see table below
├── terraform/
│   └── environments/
│       └── dev/
│           └── main.tf         # currently empty — M1 module code lands here next
└── LICENSE
```

`terraform/modules/`, `backstage/`, and `docs/architecture/` will appear as each milestone is actually implemented — they are not scaffolded yet.

---

## Security by Design (target for M1–M3)

| Layer | Implementation |
| --- | --- |
| **Infrastructure** | Azure Policy (Deny mode), CIS Benchmark alignment, NSG micro-segmentation |
| **Identity** | Managed Identity, RBAC/PIM on critical resources |
| **Secrets** | Key Vault, no static credentials in pipelines |
| **Pipeline** | tfsec (fast pre-merge scan) + Checkov (deeper policy-as-code, CIS mapping) — kept intentionally distinct roles, see [ADR note](docs/adr/002-why-hub-spoke.md), Trivy, Gitleaks |
| **Runtime** | Defender for Cloud aligned to CIS Benchmarks |

---

## Architecture Decision Records

| ADR | Decision | Status |
| --- | --- | --- |
| [ADR-001](docs/adr/001-why-terraform.md) | Why Terraform over Bicep/Pulumi? | ✅ Accepted |
| [ADR-002](docs/adr/002-why-hub-spoke.md) | Why Hub & Spoke topology? | ✅ Accepted |
| [ADR-003](docs/adr/003-why-github-actions.md) | Why GitHub Actions over Azure DevOps? | ✅ Accepted |
| [ADR-004](docs/adr/004-why-private-endpoints.md) | Why Private Endpoints and no Azure Firewall in MVP? | ✅ Accepted |
| [ADR-005](docs/adr/005-why-backstage.md) | Why Backstage for the self-service portal? | 🚧 Draft |
| [ADR-006](docs/adr/006-why-argocd.md) | Why ArgoCD for GitOps? | 💡 Future consideration — not part of the current roadmap |
| [ADR-007](docs/adr/007-separation-network-security.md) | Separation of Duties — Network vs Security | ✅ Accepted |
| [ADR-008](docs/adr/008-team-structure-governance.md) | Team Structure and Governance Model | ✅ Accepted |
| [ADR-009](docs/adr/009-key-vault-separation.md) | Key Vault Separation — platform/pipeline secrets vs Backstage app secrets | ✅ Accepted |
| [ADR-010](docs/adr/010-terraform-bootstrap-strategy.md) | Terraform Bootstrap Strategy — solving the backend/Key Vault chicken-and-egg problem | ✅ Accepted |
| [ADR-011](docs/adr/011-dependency-management-strategy.md) | Dependency Management Strategy — AVM version pinning + Dependabot over Renovate | ✅ Accepted |

---

## Getting Started *(target workflow once M1 lands)*

### Prerequisites

- Azure subscription (used in dry-run/plan mode first — see note below)
- Terraform >= 1.6
- Azure CLI >= 2.50

### Deploy M1 Landing Zone

```bash
git clone https://github.com/mariano-forge/nexus-azure-platform.git
cd nexus-azure-platform/terraform/environments/dev

terraform init
terraform plan     # safe — no resources created, review only
# terraform apply  # will be re-enabled once the M1 modules are implemented and tested
```

> This project is validated in `terraform plan` / dry-run first, against real modules once written, before any real subscription is provisioned. The `apply` step above is intentionally commented out until M1 code is merged and verified — this README will be updated the day it's safe to run.

---

## DevSecOps Pipeline (implemented today)

Every Pull Request triggers:

| Step | Tool | Purpose |
| --- | --- | --- |
| 1️⃣ | Super Linter (tflint, Markdown, YAML, JSON) | Style and lint |
| 2️⃣ | Terraform fmt / validate | Formatting and syntax |
| 3️⃣ | tfsec | Fast infra security scan |
| 4️⃣ | Checkov | Deeper policy-as-code + CIS mapping |
| 5️⃣ | Trivy | Vulnerability scanning |
| 6️⃣ | Gitleaks | Secret detection |
| ⏸️ | Manual Approval | Required before apply on critical environments |

---

## Dependency Management

Reusable modules are wrapped **Azure Verified Modules (AVM)**, with every version pinned explicitly — no floating versions in `terraform` blocks.

Keeping pinned versions current is handled by **Dependabot** (native to GitHub, no server or scheduled job to maintain):

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "terraform"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "terraform"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

- Dependabot opens a PR for every new AVM/provider/action version it finds — the existing `pr-validation.yml` pipeline runs on it like any other PR (`terraform plan`, tfsec, Checkov).
- Dependabot does not run its own functional or smoke tests — validation of a version bump relies entirely on `terraform plan` plus manual review before merge, consistent with the dry-run-first approach used for the rest of this project.
- Dependabot Security Updates (CVE-triggered PRs) are enabled separately in repo settings, independent of the weekly schedule above.

---

## License

Licensed under the **Apache License 2.0** — see [LICENSE](LICENSE).

---

## Connect

**Mariano Gbego** · Platform / DevSecOps Engineer

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/mariano-gbego-4692651a5)
[gbegomariano@gmail.com](mailto:gbegomariano@gmail.com)

---

<div align="center">
<sub>Built incrementally. Documented honestly. Secured by design.</sub>
</div>
