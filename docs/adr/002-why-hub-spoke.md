# ADR-002: Why Hub & Spoke Topology?

**Status:** ✅ Accepted  
**Date:** 2026-07-21  
**Author:** Mariano Gbego  
**Context:** Nexus Azure Platform

---

## Context

We need to design the Azure network architecture for the Nexus Azure Platform.

The architecture must support:

- Multiple environments (dev, staging, prod) isolated from each other
- Centralized security and governance controls
- Connectivity between all environments and shared services
- Private access to PaaS services (Key Vault, Storage, etc.)
- Scalability for future workloads and teams
- Cost optimization

The two primary architectural patterns considered are:

- **Hub & Spoke** : A central hub VNet with shared services, and spoke VNets for workloads.
- **Flat VNet** : A single large VNet with all resources and subnets.

---

## Decision

We will use the **Hub & Spoke** topology.

---

## Rationale

| Criteria | Hub & Spoke | Flat VNet |
| :--- | :--- | :--- |
| **Security** | ✅ Centralized firewall, NSGs, and Azure Policies | ⚠️ Distributed security controls, harder to enforce |
| **Governance** | ✅ Centralized management and monitoring | ❌ Decentralized, harder to audit |
| **Scalability** | ✅ Easily add new spokes for new workloads | ⚠️ Limited by VNet size (65,536 IPs) |
| **Resource Isolation** | ✅ Clear separation per environment (each env = one spoke) | ❌ Subnets only, but still in same VNet |
| **Cost** | ⚠️ Peering costs (ingress/egress) | ✅ No peering costs |
| **Compliance** | ✅ Easier to enforce compliance per spoke | ❌ Harder to segment compliance boundaries |
| **Future Hybrid** | ✅ Pattern extends naturally to hybrid connectivity (VPN/ExpressRoute) | ❌ Azure-only approach |

---

## Consequences

### Positive

- **Security by default**: Centralized Azure Firewall/NSG policies in the hub enforce security across all spokes.
- **Governance**: Single place to manage Azure Policies, RBAC, and monitoring.
- **Scale**: New teams or workloads can be added as new spokes without impacting existing ones.
- **Clear environment separation**: Each environment (dev, staging, prod) can be a separate spoke, preventing cross-environment contamination.

### Negative

- **Peering complexity**: VNet peering must be configured between hub and each spoke.
- **Cost**: VNet peering incurs ingress/egress charges (data transfer).
- **Latency**: Traffic between spokes goes through the hub, potentially adding minimal latency.

---

---

## When to Reconsider

This decision should be revisited if any of the following conditions occur:

1. **Multi-Region Expansion**  
   - If the platform expands to multiple Azure regions, the Hub & Spoke model becomes complex to manage across regions.  
   - **Action**: Evaluate **Azure Virtual WAN** as a replacement. Virtual WAN provides native multi-region connectivity, centralized routing, and simplified hub-spoke management across regions.  
   - *Note*: Virtual WAN is overkill for single-region deployments but becomes cost-effective and operationally superior at scale.

2. **Significant Peering Costs**  
   - If data transfer between hubs and spokes becomes substantial (e.g., large-scale data movement, frequent inter-spoke communication), VNet peering costs may become significant.  
   - **Action**: Re-evaluate against Virtual WAN pricing. Virtual WAN uses a different billing model (per-hour hub + per-GB traffic) that may be more cost-effective at high throughput.  
   - *Note*: This is a FinOps consideration — we monitor peering costs continuously via Azure Cost Management.

3. **New Azure Networking Capabilities**  
   - If Azure introduces a new networking pattern that offers better cost, performance, or management capabilities.

---

## Alternatives Considered

1. **Flat VNet**  
   - *Why rejected?* No central governance, harder to manage security policies, and limited scalability for large teams.

2. **Azure Virtual WAN**  
   - *Why rejected?* Overkill for a single-region deployment with no branch office connectivity. Adds complexity and cost.

3. **Multiple independent VNets**  
   - *Why rejected?* No centralized management for shared services (Key Vault, monitoring), leading to duplication and configuration drift.

---

## Related ADRs

- [ADR-001](001-why-terraform.md) : Terraform will be used to deploy the Hub & Spoke networking.
- [ADR-004](004-why-private-endpoints.md) : Private Endpoints will be used for PaaS services in the hub.

---

## References

- [Azure Hub-Spoke Network Topology](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [VNet Peering Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
- [Azure Private Endpoint Documentation](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [Azure Virtual WAN Documentation](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about)
- [Virtual WAN Pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-wan/)
- [Azure Private Endpoint Documentation](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)

---

## Changelog

| Date | Author | Changes |
| :--- | :--- | :--- |
| 2026-07-21 | Mariano Gbego | Initial draft |

---

*This ADR follows the [Nexus Azure Platform ADR Template](_template.md).*
