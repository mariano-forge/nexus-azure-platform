# Architecture Overview

## System diagram

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

!!! note "C4 diagrams coming in M1"
    C4 Level 1 (System Context) and Level 2 (Container) diagrams will be added here once the Terraform modules are implemented and the actual deployed topology can be documented accurately.

---

## Security by design

| Layer | Implementation |
|---|---|
| **Infrastructure** | Azure Policy (Deny mode), CIS Benchmark alignment, NSG micro-segmentation |
| **Identity** | Managed Identity, RBAC/PIM on critical resources |
| **Secrets** | Two dedicated Key Vaults (pipeline vs app — see [ADR-009](../adr/009-key-vault-separation.md)) — no static credentials in pipelines |
| **Pipeline** | tfsec + Checkov (CIS mapping), Trivy, Gitleaks — see [DevSecOps Pipeline](../platform-engineering/devsecops-pipeline.md) |
| **Runtime** | Defender for Cloud aligned to CIS Benchmarks |

---

## Networking model

The platform uses a **Hub & Spoke** topology — see [ADR-002](../adr/002-why-hub-spoke.md) for the full rationale.

Key choices:

- **No Azure Firewall in the MVP** — NSGs + Private Endpoints instead, saving ~300€/month — [ADR-004](../adr/004-why-private-endpoints.md)
- **Private DNS Zones** for all PaaS services (Key Vault, Storage, Azure Monitor)
- **Deny-all** inbound/outbound NSG rules by default; explicit allow-only where necessary
- **VNet Peering** prepared for future spokes; spoke provisioning is self-service via Backstage (M2)

---

## Team ownership model

Four teams own distinct platform domains, enforced via GitHub CODEOWNERS — see [ADR-007](../adr/007-separation-network-security.md) and [ADR-008](../adr/008-team-structure-governance.md):

| Team | Domain | Key resources |
|---|---|---|
| `governance` | Cloud governance | Management Groups, Azure Policies, root RBAC |
| `network` | Connectivity | Hub & Spoke VNets, Private DNS, NSGs |
| `security` | Security & compliance | Key Vault, Defender for Cloud, PIM |
| `platform-engineering` | Developer experience | AKS, Backstage, Observability, CI/CD |

Changes to production environments require approval from all four teams. Changes to critical files (`.github/`, ADRs, README) follow the same rule.
