<!--
  Nexus Azure Platform - Enterprise Internal Developer Platform Blueprint
  Copyright 2026 Mariano Gbego
  Licensed under Apache 2.0
-->

<div align="center">

# Nexus Azure Platform

**A production-grade Enterprise Azure Platform built with security-first Platform Engineering principles.**

*Designed for teams. Documented for humans. Secured by design.*

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Cloud-Azure-0078D4)](https://azure.microsoft.com)
[![Backstage](https://img.shields.io/badge/IDP-Backstage-9B59B6)](https://backstage.io/)
[![Status](https://img.shields.io/badge/Status-MVP%20In%20Progress-yellow)](https://github.com/mariano-gbego/nexus-azure-platform/projects)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)](CONTRIBUTING.md)

</div>

---

## What is Nexus Azure Platform?

Nexus Azure Platform is an open-source reference implementation of an **Internal Developer Platform (IDP)** on Azure.

It answers a concrete question:

> *How do you build a cloud platform that 500 developers can use autonomously — without sacrificing security, governance, or operational visibility?*

This is not a collection of scripts.  
This is not a tutorial.  
This is a platform designed the way it would be designed in production:  
with trade-offs documented, decisions justified, and security embedded from day one.

---

## Why this project?

Most cloud infrastructure projects show **what** to deploy.  
Nexus Azure Platform shows **why every decision was made**.

Each architectural choice — networking topology, secret management strategy, GitOps tooling — is documented in an Architecture Decision Record (ADR).

You will find not just the implementation, but the reasoning behind it.

> 💡 **Why no Azure Firewall in the MVP?**  
> To keep the blueprint **cost-optimized** and accessible for open-source contributions, this MVP uses NSGs with Service Tags and Private Endpoints for network security — saving ~300€/month. Enterprises can easily swap in Azure Firewall if needed. See [ADR-004](docs/adr/004-why-private-endpoints.md).

---

## The scenario

Imagine a company with 500 developers adopting Azure.

They need:
- A secure, governed Landing Zone
- A self-service portal to provision environments without opening a ticket
- Standardized, security-scanned CI/CD pipelines
- Full observability across all workloads
- An AI assistant that understands their platform

Nexus Azure Platform is the answer to that need.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   Nexus Azure Platform                      │
│                                                             │
│  ┌─────────────┐   ┌──────────────┐   ┌─────────────────┐  │
│  │  Landing    │   │  Developer   │   │   AI-Powered    │  │
│  │  Zone       │──▶│  Self-Service│──▶│   Operations    │  │
│  │  (Terraform)│   │  (Backstage) │   │  (OpenAI + n8n) │  │
│  └─────────────┘   └──────────────┘   └─────────────────┘  │
│         │                 │                    │            │
│         ▼                 ▼                    ▼            │
│  ┌─────────────┐   ┌──────────────┐   ┌─────────────────┐  │
│  │  Security   │   │   GitOps     │   │  Observability  │  │
│  │  by Design  │   │  (ArgoCD)    │   │  (Prometheus /  │  │
│  │             │   │              │   │   Grafana / OTel)│  │
│  └─────────────┘   └──────────────┘   └─────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

> Full C4 diagrams are available in the [documentation](./docs/architecture/).

---

## 🗺️ Roadmap & Milestones

Check our [GitHub Project Board](https://github.com/mariano-gbego/nexus-azure-platform/projects) for live progress!

| # | Milestone | Status | Description |
|---|-----------|--------|-------------|
| **M1** 🏗️ | **Landing Zone & Core Security** | 🚧 In Progress | Terraform modules for Hub/Spoke networking, Private DNS, Private Endpoints, Key Vault, Log Analytics. Azure Policies, RBAC, PIM. DevSecOps pipeline (tfsec, Checkov, Trivy, manual approval). |
| **M2** 🧩 | **Developer Self-Service** | 📅 Planned | Backstage portal, Software Templates (Scaffolder), MkDocs documentation site, C4 diagrams, first ADRs. |
| **M3** ⚙️ | **GitOps & Advanced Governance** | 📅 Planned | ArgoCD + Helm/Kustomize, Azure PIM, Defender for Cloud, automated secret rotation. |
| **M4** 📊 | **Observability & FinOps** | 📅 Planned | Prometheus, Grafana, Loki, SLO/SLI definitions, Azure budgets, cost dashboards. |
| **M5** 🤖 | **AI-Powered Operations** | 📅 Planned | Azure OpenAI, n8n orchestrator, Backstage AI Assistant, RAG over ADRs & logs. |

---

## What's inside

```
nexus-azure-platform/
├── terraform/                  # All infrastructure as code
│   ├── modules/                # Reusable Terraform modules
│   │   ├── landing-zone/       # Management Groups, Subscriptions
│   │   ├── networking/         # Hub & Spoke, Private DNS, Private Endpoints
│   │   ├── security/           # Key Vault, Defender, Policies
│   │   ├── aks/                # Kubernetes clusters
│   │   └── observability/      # Log Analytics, Monitor
│   └── environments/           # Per-environment configurations
│       ├── dev/
│       ├── staging/
│       └── prod/
├── .github/
│   └── workflows/              # CI/CD pipelines
│       ├── pr-validation.yml   # Format, Lint, tfsec, Checkov, Trivy
│       └── deploy.yml          # Plan, Approve, Apply, Smoke tests
├── backstage/                  # Internal Developer Portal
│   └── templates/              # Self-service scaffolder templates
├── gitops/                     # ArgoCD applications & Helm charts
├── docs/                       # MkDocs documentation site
│   ├── architecture/           # C4 diagrams, design docs
│   ├── adr/                    # Architecture Decision Records
│   ├── runbooks/               # Operational runbooks
│   └── onboarding/             # Getting started guides
└── ai/                         # AI-Powered Operations
    ├── rag/                    # RAG pipeline over ADRs
    └── workflows/              # n8n workflow definitions
```

---

## Security by Design

Security is not a layer added on top. It is embedded in every component.

| Layer | Implementation |
|-------|---------------|
| **Infrastructure** | Azure Policy (Deny mode), CIS Benchmark, NSG micro-segmentation |
| **Identity** | Workload Identity, Managed Identity, PIM |
| **Secrets** | Key Vault, automated rotation, no static credentials |
| **Pipeline** | tfsec, Checkov, Trivy, Gitleaks, OPA/Conftest |
| **Runtime** | Defender for Cloud, Network Policies |
| **AI** | Prompt injection detection, OWASP LLM Top 10 |

---

## Architecture Decision Records

Every major decision is documented and justified. This is what makes Nexus Azure Platform **a learning resource, not just code**.

See the [ADR Template](docs/adr/_template.md) to learn how to create one.

| ADR | Decision | Status |
|-----|----------|--------|
| [ADR-001](docs/adr/001-why-terraform.md) | Why Terraform over Bicep/Pulumi? | ✅ Accepted |
| [ADR-002](docs/adr/002-why-hub-spoke.md) | Why Hub & Spoke topology? | ✅ Accepted |
| [ADR-003](docs/adr/003-why-github-actions.md) | Why GitHub Actions over Azure DevOps? | ✅ Accepted |
| [ADR-004](docs/adr/004-why-private-endpoints.md) | Why Private Endpoints and no Azure Firewall in MVP? | ✅ Accepted |
| [ADR-005](docs/adr/005-why-backstage.md) | Why Backstage for the IDP? | 🚧 Draft |
| [ADR-006](docs/adr/006-why-argocd.md) | Why ArgoCD for GitOps? | 🚧 Draft |
| [ADR-007](docs/adr/007-separation-network-security.md) | Separation of Duties — Network vs Security Teams | ✅ Accepted |
| [ADR-008](docs/adr/008-team-structure-governance.md) | Team Structure and Governance Model | ✅ Accepted |

> ADRs are continuously added as the platform evolves.

---

## Getting Started

### Prerequisites

- Azure subscription (free trial works)
- Terraform >= 1.6
- Azure CLI >= 2.50
- GitHub account (for CI/CD)

### Quick Start — Deploy M1 Landing Zone

```bash
# Clone the repository
git clone https://github.com/mariano-gbego/nexus-azure-platform.git
cd nexus-azure-platform

# Authenticate to Azure
az login
az account set --subscription "<your-subscription-id>"

# Deploy the Landing Zone
cd terraform/environments/dev
terraform init
terraform plan    # Review what will be created
terraform apply   # ⚠️ This will incur Azure costs
```

> ⚠️ **Cost warning:** This deploys real Azure resources. Always run `terraform destroy` when done to avoid unexpected charges. See [docs/onboarding/cost-estimation.md](docs/onboarding/cost-estimation.md) for details.

### Clean up

```bash
cd terraform/environments/dev
terraform destroy
```

---

## DevSecOps Pipeline

Every Pull Request triggers a comprehensive validation pipeline:

| Step | Tool | Purpose |
|------|------|---------|
| 1️⃣ | Terraform fmt | Enforce code style |
| 2️⃣ | Terraform validate | Syntax and logic check |
| 3️⃣ | tfsec | Infrastructure security scanning |
| 4️⃣ | Checkov | Policy-as-Code validation |
| 5️⃣ | Trivy | Vulnerability scanning |
| 6️⃣ | Gitleaks | Secret detection |
| 7️⃣ | OPA/Conftest | Custom policy enforcement |
| 8️⃣ | Terraform Plan | Preview changes |
| ⏸️ | Manual Approval | Required before apply on main |
| 9️⃣ | Terraform Apply | Execute the deployment |
| 🔟 | Smoke Tests | Post-deployment validation |

---

## Contributing

Nexus Azure Platform is open to contributions of all kinds.

- New to open-source? Check out [`good first issue`](../../issues?q=label%3A%22good+first+issue%22).
- Want to help? See the [Contribution Guide](CONTRIBUTING.md).
- Have an idea? Open an issue or start a discussion.

Every contribution is reviewed against the security and architecture standards documented in the ADRs.

---

## License

This project is licensed under the **Apache License 2.0** — see the [LICENSE](LICENSE) file for details.

This choice ensures maximum enterprise adoption while protecting contributors and users with patent grants.

---

## Connect

**Mariano Gbego** · Platform Engineer · Security-First

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/mariano-gbego-4692651a5)
✉️ gbegomariano@gmail.com

---

<div align="center">
<sub>Built with intention. Documented with care. Secured by design.</sub>
</div>