# ADR-004: Why Private Endpoints and No Azure Firewall (MVP)?

**Status:** ✅ Accepted  
**Date:** 2026-07-21  
**Author:** Mariano Gbego  
**Context:** Nexus Azure Platform

---

## Context

We need to secure all network traffic for the Nexus Azure Platform, particularly access to PaaS services (Key Vault, Storage, Azure Monitor, etc.) and workload isolation.

The platform must:

- Keep all data private (no public internet exposure for PaaS services)
- Enforce network segmentation and access control
- Be **cost-optimized** for open-source contributors (MVP phase)
- Allow future evolution to enterprise-grade network security

The primary approaches considered:

- **Azure Firewall** : Fully managed, stateful firewall with L3-L7 inspection, FQDN filtering, and threat intelligence.
- **NSGs + Private Endpoints** : Network Security Groups for micro-segmentation + Private Endpoints to bring PaaS services into the VNet.
- **Service Endpoints** : Expose PaaS services to the VNet via Azure backbone, but still use public IPs.

---

## Decision

We will **not** deploy Azure Firewall in the MVP. Instead, we will use:

- **Private Endpoints** : For all PaaS services (Key Vault, Storage, Azure Monitor, etc.) to make them entirely private.
- **NSGs (Network Security Groups)** with Service Tags for micro-segmentation at the subnet level.
- **Deny all** inbound/outbound rules by default, with explicit allow rules only where necessary.

---

## Rationale

| Criteria | NSGs + Private Endpoints | Azure Firewall | Service Endpoints |
| :--- | :--- | :--- | :--- |
| **Cost (MVP)** | ✅ **~0€** (NSGs free, Private Endpoints ~7€/month) | ❌ **~300€/month** (Basic tier) | ✅ Free (part of VNet) |
| **Traffic Privacy** | ✅ Full private (PaaS uses private IPs) | ✅ Full private | ⚠️ Public IP still exposed to Azure backbone |
| **L3-L7 Inspection** | ❌ No L7 (Application layer) | ✅ Full L7 inspection | ❌ No inspection |
| **FQDN Filtering** | ❌ Not possible | ✅ Possible | ❌ Not possible |
| **Security Complexity** | ✅ Simple (SG-based) | ⚠️ Complex (ruleset management) | ✅ Simple |
| **Open-Source Friendly** | ✅ Low barrier to test/contribute | ❌ High cost barrier | ✅ Low barrier |
| **Enterprise Readiness** | ⚠️ Good for Dev/Staging | ✅ Production-grade | ⚠️ Less secure |

---

### NSG Strategy

- **Default Deny** : NSGs deny all inbound/outbound traffic by default.
- **Service Tags** : Allow specific Azure Service Tags (e.g., `AzureKeyVault`, `AzureMonitor`) for required services.
- **Spoke-to-Hub Routing** : Force tunneling via the Hub to centralize egress filtering.

### Cost Comparison (Monthly, MVP)

| Service | Cost |
| :--- | :--- |
| Azure Firewall (Basic) | ~300€ |
| Private Endpoints (x5) | ~35€ |
| **Total MVP Cost** | **~25€** |
| **Savings vs Firewall** | **~265€/month** |

> *Note: This makes the blueprint accessible to individual developers, open-source contributors, and small teams.*

---

## Consequences

### Positive

- **Cost Optimization**: Saves ~300€/month on infrastructure costs.
- **Accessibility**: Low barrier to entry for open-source contributors (no huge recurring cost).
- **Security**: Private Endpoints ensure PaaS services are not exposed to the public internet.
- **Compliance**: Data stays within the Azure private backbone.
- **Simplicity**: NSG rules are easier to manage than complex firewall policies.

### Negative

- **Limited L7 Inspection**: Without Azure Firewall, we cannot perform deep packet inspection (e.g., SQL injection detection, FQDN filtering).
- **No Centralized Egress Control**: Egress filtering relies on NSGs per subnet, not a single pane of glass.
- **Complex DNS**: Requires managing Private DNS Zones for each PaaS service.

---

## When to Reconsider

This decision should be revisited if any of the following conditions occur:

1. **Production Compliance Requirements**  
   - If a security audit mandates FQDN filtering, TLS inspection, or Intrusion Detection/Prevention (IDS/IPS).  
   - **Action**: Azure Firewall (Standard or Premium) can be introduced as a replacement for NSGs. The architecture (Hub & Spoke) is already designed to support this swap.

2. **Egress Traffic Growth**  
   - If egress traffic increases significantly (e.g., large data exports, internet-facing apps), making centralized monitoring and filtering essential.

3. **Hybrid Connectivity**  
   - If the platform connects to on-premises via VPN/ExpressRoute and requires tight integration with enterprise network policies.

4. **Cost to Complexity Trade-off**  
   - If the complexity of managing Private DNS Zones and NSGs outweighs the cost savings.

---

## Alternatives Considered

1. **Azure Firewall**  
   - *Why rejected for MVP?* High cost (~300€/month) creates a barrier for open-source adoption.

2. **Service Endpoints**  
   - *Why rejected?* Service Endpoints still expose PaaS services to the Azure backbone with public IPs. Private Endpoints offer a higher security baseline.

3. **Third-Party Firewall (Palo Alto, Fortinet)**  
   - *Why rejected?* Even more expensive and complex to deploy.

---

## Related ADRs

- [ADR-002](002-why-hub-spoke.md) : Private Endpoints are placed in the Hub VNet for centralized access.
- [ADR-001](001-why-terraform.md) : Terraform modules will automate Private Endpoint creation.

---

## References

- [Azure Private Endpoint Documentation](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [Azure Firewall Pricing](https://azure.microsoft.com/en-us/pricing/details/azure-firewall/)
- [Service Tags Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/service-tags-overview)
- [NSG Best Practices](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)

---

## Changelog

| Date | Author | Changes |
| :--- | :--- | :--- |
| 2026-07-21 | Mariano Gbego | Initial draft |

---

*This ADR follows the [Nexus Azure Platform ADR Template](_template.md).*
