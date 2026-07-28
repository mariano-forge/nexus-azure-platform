# Milestones — Nexus Azure Platform

This is the actual, committed scope (see README → "Project status"). Anything beyond M3 is documented under "Beyond this repo" as design-only — not tracked as a milestone until it's actually built.

---

## M1 — Landing Zone & Core Security

**tl;dr** — A real, deployed, secured Azure Landing Zone (Hub & Spoke + Private DNS + Key Vault + Log Analytics) with a working DevSecOps validation pipeline and documented ADRs.

### Infrastructure & Connectivity (Stages 0–1)

- **Governance** (`0-governance`): Management Groups (Corp, Online, Sandbox, Platform, LandingZones), Azure Policies in Deny mode (tagging, CIS Benchmark alignment, region restriction), root-level RBAC, base subscriptions
- **Connectivity** (`1-connectivity`): Hub VNet with dedicated subnets, Private DNS Zones for PaaS services, NSGs with Service Tags, VNet Peering prepared for future spokes

### Security & Observability (Stages 2–3)

- **Security**: Centralized Key Vault (Terraform backend secrets, GitHub tokens), Defender for Cloud aligned to CIS Benchmarks, RBAC/PIM on critical resources, deny-public-access policies
- **Observability (basic)**: Centralized Log Analytics Workspace, 30-day retention (cost-conscious default), basic cost/availability alerts, Automation Account provisioned (used for the one real runbook in M3)

### DevSecOps Pipeline (implemented)

- Super Linter (tflint, Markdown, YAML, JSON)
- Terraform `fmt` / `validate`
- **tfsec** (fast pre-merge scan) + **Checkov** (deeper policy-as-code, CIS mapping) — both kept intentionally, distinct roles
- Trivy (container vulnerabilities, if applicable)
- Gitleaks (secret detection)
- Manual approval before `terraform apply` on critical environments

### Documentation & ADRs - M1

- MkDocs site
- ADRs for all key decisions (already: ADR-001 to ADR-004, ADR-007, ADR-008)
- C4 diagrams (Level 1 & 2) once the modules exist

### Validation approach

Validated in `terraform plan` / dry-run against every module first. A minimal real `apply` (Stage 0–1 only, in a single Sandbox subscription) follows once the plan is clean, to catch what dry-run can't (DNS resolution, effective NSG rules, policy enforcement behavior) — before scaling to the full structure.

### Cost guardrails

- No Azure Firewall in the MVP (NSGs + Private Endpoints instead — see ADR-004, ~800€/month saved)
- Auto-shutdown schedules on non-production resources

---

## M2 — Developer Self-Service

**tl;dr** — Backstage portal, deployed for real, with exactly two working scaffolder templates: subscription vending and VNet vending — plus a real PR-based approval flow.

### Backstage Portal

- Node backend + **Azure Database for PostgreSQL Flexible Server (Burstable)** for catalog persistence — required, not optional
- Deployed on App Service (B1 Basic tier for testing)
- Scaffolder templates: **"Create a subscription"** (Subscription Vending), **"Create an application VNet"** (Spoke) — no Storage/AKS templates in this milestone
- Input guardrails: allow-listed regions/SKUs on template parameters, enforced a second time by Azure Policy `deny` rules

### Approval Workflow (explicit mechanism)

- Scaffolder templates generate a **Terraform PR** rather than applying directly
- **CODEOWNERS** on the corresponding IaC path assigns the approver
- Merge of the approved PR triggers the GitHub Actions apply workflow
- Approval history and audit trail visible in GitHub

### Budgets (minimal, tied to M1's cost guardrails)

- A budget resource (`azurerm_consumption_budget`) is created by the **same Terraform module** that provisions a new subscription — IaC-driven, not a manual step
- Mandatory tags enforced by Azure Policy: `costCenter`, `application`, `environment`, `owner`

### Documentation & ADRs - M2

- MkDocs: Backstage user guide, self-service templates guide, approval workflow documentation
- ADR-005 (Backstage), plus a new ADR documenting the PR/CODEOWNERS approval mechanism

### Dependencies - M2

- **Depends on:** M1
- **Prerequisites:** Backstage + Postgres, Log Analytics, Key Vault (all M1)
- **Provides:** real self-service subscription/VNet provisioning through a governed, human-approved workflow

---

## M3 (partial) — Basic Observability

**tl;dr** — One platform health dashboard, and exactly one real, tested auto-remediation runbook — not the full observability/auto-remediation suite.

### Observability

- Platform Health Dashboard (Grafana or Azure Workbooks — pick one, not both, to avoid rebuilding the same view twice)
- Alerting via **Azure Monitor Dynamic Thresholds** (named explicitly — not "ML-powered" as a vague label)
- Alerts routed to Email/Slack (Teams optional)

### Auto-Remediation (one runbook, done properly)

- **Auto-restart**: restart a failed App Service or VM, triggered by an Azure Monitor alert
- Runbook stored in GitHub (Terraform + PowerShell/Python), version-controlled, deployed via CI/CD
- Runbook logs sent to Log Analytics
- If remediation fails, escalate to the same Slack/Teams channel already used for alerts — no new on-call tool introduced for this milestone

*(Auto-scale, auto-cleanup, auto-patch, and the previously-proposed "auto-budget" are explicitly out of scope here — see "Beyond this repo" in the README. They add real testing burden — canary rollout, dry-run modes — that isn't worth it for a single demonstrated runbook.)*

### Documentation & ADRs - M3

- MkDocs: observability runbook, incident response guide
- New ADR: Observability & Auto-Remediation scope for the MVP (why only one runbook, why Dynamic Thresholds over a custom ML model)

### Dependencies - M3

- **Depends on:** M1, M2
- **Prerequisites:** Log Analytics, Automation Account (M1), App Service (M2)
- **Provides:** a working, end-to-end demonstration of the observability → alert → automated remediation loop, with a documented boundary on what's automated and what isn't

---

## Outcome (after M1–M3)

- A landing zone that is **actually deployed and secured**, not just described
- A self-service portal where a developer can **really** request a subscription or VNet and see it provisioned through a governed approval flow
- One working example of the observability → remediation loop, with its safety limits explicit
- Everything beyond this is documented reasoning (ADRs), not a promise of delivered code — see the README's "Beyond this repo" section
