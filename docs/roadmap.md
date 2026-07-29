# Roadmap

This is the actual, committed scope. Anything beyond M3 is documented under "Beyond this repo" as design-only — not tracked as a milestone until it's actually built.

---

## M1 — Landing Zone & Core Security

**Status: 🚧 In Progress**

> A real, deployed, secured Azure Landing Zone (Hub & Spoke + Private DNS + Key Vault + Log Analytics) with a working DevSecOps validation pipeline and documented ADRs.

### Infrastructure & Connectivity (Stages 0–1)

- **Governance** (`0-governance`): Management Groups (Corp, Online, Sandbox, Platform, LandingZones), Azure Policies in Deny mode (tagging, CIS Benchmark alignment, region restriction), root-level RBAC, base subscriptions
- **Connectivity** (`1-connectivity`): Hub VNet with dedicated subnets, Private DNS Zones for PaaS services, NSGs with Service Tags, VNet Peering prepared for future spokes

### Security & Observability (Stages 2–3)

- **Security**: Centralized Key Vault (Terraform backend secrets, GitHub tokens), Defender for Cloud aligned to CIS Benchmarks, RBAC/PIM on critical resources, deny-public-access policies
- **Observability (basic)**: Centralized Log Analytics Workspace, 30-day retention (cost-conscious default), basic cost/availability alerts, Automation Account provisioned (used for the one real runbook in M3)

### DevSecOps Pipeline

- Super Linter (tflint, Markdown, YAML, JSON)
- Terraform `fmt` / `validate`
- **tfsec** (fast pre-merge scan) + **Checkov** (deeper policy-as-code, CIS mapping) — both kept intentionally, distinct roles
- Trivy (container vulnerabilities, if applicable)
- Gitleaks (secret detection)
- Manual approval before `terraform apply` on critical environments

See [DevSecOps Pipeline](platform-engineering/devsecops-pipeline.md) for the current implementation status of each step.

### Validation approach

Validated in `terraform plan` / dry-run against every module first. A minimal real `apply` (Stage 0–1 only, in a single Sandbox subscription) follows once the plan is clean — to catch what dry-run can't (DNS resolution, effective NSG rules, policy enforcement behavior) — before scaling to the full structure.

### Cost guardrails

- No Azure Firewall in the MVP (NSGs + Private Endpoints instead — see [ADR-004](adr/004-why-private-endpoints.md), ~300€/month saved)
- Auto-shutdown schedules on non-production resources

---

## M2 — Developer Self-Service

**Status: 📅 Planned** · Depends on M1

> Backstage portal, deployed for real, with exactly two working scaffolder templates: subscription vending and VNet vending — plus a real PR-based approval flow.

### Backstage Portal

- Node backend + **Azure Database for PostgreSQL Flexible Server (Burstable)** for catalog persistence — required, not optional
- Deployed on App Service (B1 Basic tier for testing)
- Scaffolder templates: **"Create a subscription"** (Subscription Vending), **"Create an application VNet"** (Spoke) — no Storage/AKS templates in this milestone
- Input guardrails: allow-listed regions/SKUs on template parameters, enforced a second time by Azure Policy `deny` rules

### Approval workflow

- Scaffolder templates generate a **Terraform PR** rather than applying directly
- **CODEOWNERS** on the corresponding IaC path assigns the approver
- Merge of the approved PR triggers the GitHub Actions apply workflow
- Approval history and audit trail visible in GitHub

### Budgets

- A `azurerm_consumption_budget` resource is created by the **same Terraform module** that provisions a new subscription — IaC-driven, not a manual step
- Mandatory tags enforced by Azure Policy: `costCenter`, `application`, `environment`, `owner`

---

## M3 (partial) — Basic Observability

**Status: 📅 Planned** · Depends on M1, M2

> One platform health dashboard, and exactly one real, tested auto-remediation runbook — not the full observability/auto-remediation suite.

### Observability

- Platform Health Dashboard (Grafana or Azure Workbooks — pick one, not both)
- Alerting via **Azure Monitor Dynamic Thresholds** (not "ML-powered" as a vague label)
- Alerts routed to Email/Slack (Teams optional)

### Auto-remediation (one runbook, done properly)

- **Auto-restart**: restart a failed App Service or VM, triggered by an Azure Monitor alert
- Runbook stored in GitHub (Terraform + PowerShell/Python), version-controlled, deployed via CI/CD
- Runbook logs sent to Log Analytics
- If remediation fails, escalate to the same Slack/Teams channel used for alerts

!!! note "Explicit scope boundary"
    Auto-scale, auto-cleanup, auto-patch, and auto-budget are explicitly out of scope for M3. They add real testing burden (canary rollout, dry-run modes) that isn't justified for a single demonstrated runbook.

---

## Beyond this repo (design only)

These are documented as ADRs or design exercises to show the reasoning behind a larger platform vision. They are **not** tracked as milestones until actually built.

- **GitOps** (ArgoCD) — see [ADR-006](adr/006-why-argocd.md)
- **FinOps dashboard** integrated into Backstage
- **Full observability stack** (Prometheus/Loki/OTel) beyond the M3 basics
- **AI assistant** (RAG over ADRs, pipeline failure analysis) — any future version would enforce suggestion-only behavior and PII/secret scrubbing before data reaches an LLM

If one of these gets built for real, it moves into the Roadmap table above with a working demo — not before.
