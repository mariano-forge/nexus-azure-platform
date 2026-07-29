# Nexus Azure Platform

**A reference implementation of a secure, self-service Azure Landing Zone — with every architectural decision documented and justified.**

*Small in scope. Honest about status. Secured by design.*

---

## What it is

Nexus Azure Platform answers a narrow, concrete question:

> *What does a governed, secure Azure Landing Zone look like when developers can provision subscriptions and networks themselves — without opening a ticket — and how do you document every trade-off along the way?*

It focuses on getting two things right first:

1. A landing zone that is actually deployed and actually secured.
2. A self-service portal that actually provisions real resources through a real approval workflow.

---

## Current status

| Component | Status |
| --- | --- |
| Landing Zone Terraform modules (governance, networking, security, observability) | 🚧 In Progress |
| DevSecOps validation pipeline | ✅ Implemented |
| Backstage self-service portal (subscription + VNet vending) | 📅 Planned |
| Observability dashboard + auto-remediation runbook | 📅 Planned |

---

## Navigate

| Section | What's there |
| --- | --- |
| [Architecture](architecture/overview.md) | System diagram, security layers, team ownership model |
| [Roadmap](roadmap.md) | Detailed scope for M1, M2, M3 |
| [DevSecOps Pipeline](platform-engineering/devsecops-pipeline.md) | What runs on every PR, and why |
| [Architecture Decision Records](adr/index.md) | 11 documented decisions with rationale and trade-offs |
| [Contributing](contributing/guide.md) | How to propose a change, write an ADR, run CI locally |

---

## Why this project?

Most cloud infrastructure projects show **what** to deploy. This one also documents **why** each decision was made — including the trade-offs and what would change the decision later.

!!! example "Why no Azure Firewall in the MVP?"
    This MVP uses NSGs with Service Tags and Private Endpoints instead — saving ~300€/month versus Azure Firewall Basic. See [ADR-004](adr/004-why-private-endpoints.md) for the full trade-off and the explicit conditions under which the decision should be revisited.

---

*Built incrementally. Documented honestly. Secured by design.*
