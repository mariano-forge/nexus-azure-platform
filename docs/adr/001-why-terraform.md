# ADR-001: Why Terraform over Bicep/Pulumi?

**Status:** ✅ Accepted  
**Date:** 2026-07-21  
**Author:** Mariano Gbego  
**Context:** Nexus Azure Platform

---

## Context

We need an Infrastructure as Code (IaC) tool to deploy and manage all Azure resources for the Nexus Azure Platform.

The platform requires:

- Declarative infrastructure definitions
- State management (tracking what's deployed)
- Modularity and reusability across environments (dev, staging, prod)
- Integration with CI/CD pipelines
- Security scanning capabilities
- Support for Azure resources (AKS, VNet, Key Vault, Private Endpoints, etc.)

The primary candidates are **Terraform**, **Bicep**, and **Pulumi**.

---

## Decision

We will use **Terraform**.

---

## Rationale

| Criteria | Terraform | Bicep | Pulumi |
| :--- | :--- | :--- | :--- |
| **Maturity** | ✅ Mature (10+ years) | ✅ Mature (Growing since 2020) | ⚠️ Growing but less mature |
| **State Management** | ✅ Native (state files, remote backends) | ❌ No native state (relies on ARM) | ✅ Native |
| **Multi-Cloud** | ✅ AWS, GCP, Azure, others | ❌ Azure-only | ✅ Multi-cloud |
| **Module Registry** | ✅ Extensive public registry | ⚠️ Limited community modules | ⚠️ Growing but limited |
| **Security Scanning** | ✅ tfsec, Checkov, Trivy | ⚠️ Limited (Checkov supports Bicep but less mature) | ⚠️ Limited |
| **CI/CD Integration** | ✅ Native with GitHub Actions, GitLab, etc. | ✅ Native but Azure-centric | ✅ Good but more complex |
| **Community/Adoption** | ✅ Industry standard | ✅ Strong in Azure ecosystem | ⚠️ Smaller community |
| **Learning Curve** | ✅ Familiar to most DevOps engineers | ✅ Familiar to ARM users | ⚠️ Requires programming language (TypeScript, Python, Go) |

---

## Consequences

### Positive

- **Industry standard**: Terraform is the most widely adopted IaC tool in enterprise environments.
- **Extensive ecosystem**: Vast collection of community modules, providers, and security tools.
- **Multi-cloud flexibility**: Leaves the door open for future hybrid or multi-cloud strategies.
- **Battle-tested**: Proven in production environments at scale (e.g., Uber, Shopify, etc.).
- **Comprehensive security tooling**: tfsec, Checkov, Trivy, and OPA/Conftest are all mature and well-integrated.

### Negative

- **Learning curve**: HCL (HashiCorp Configuration Language) is declarative but requires learning.
- **State management complexity**: Remote state backends (Azure Storage) require careful configuration to avoid state corruption.
- **Plan/Apply latency**: Large deployments can take time to plan.

---

## When to Reconsider

This decision should be revisited if any of the following conditions occur:

1. **Provider Instability**  
   - If the AzureRM provider becomes unstable or introduces breaking changes that are not addressed in a timely manner.
   - If a future platform expansion requires a provider that is not well-supported by Terraform.

2. **OpenTofu Adoption**  
   - If OpenTofu becomes a team or organizational requirement.  
   - *Note*: OpenTofu is a drop-in replacement for Terraform (same HCL, same providers). Migration would be minimal, but we would need to validate compatibility with all modules and pipelines.

3. **Shift in Multi-Cloud Strategy**  
   - If the platform needs to support non-Azure cloud providers with significant workloads, and another tool (e.g., Pulumi) proves more effective for multi-cloud management.

4. **New Industry Standards**  
   - If a new IaC tool emerges that clearly surpasses Terraform in adoption, tooling, and community support.

---

## Alternatives Considered

1. **Bicep**  
   - *Why rejected?* Azure-only, limited state management, less mature security scanning ecosystem, and less portable for future multi-cloud needs.

2. **Pulumi**  
   - *Why rejected?* Smaller community, less mature security tooling, and the programming language approach (TypeScript/Python) is less accessible to pure infrastructure teams.

3. **ARM Templates**  
   - *Why rejected?* JSON-based, verbose, lacks state management, and lacks security scanning integrations.

---

## Related ADRs

- [ADR-002](002-why-hub-spoke.md) : Terraform will be used to deploy the Hub & Spoke networking topology.
- [ADR-003](003-why-github-actions.md) : Terraform will be integrated with GitHub Actions pipelines.

---

## References

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform vs Bicep vs Pulumi - A Comparison](https://www.pulumi.com/docs/iac/comparisons/terraform/)
- [tfsec Documentation](https://aquasecurity.github.io/tfsec/v1.20.0/)
- [Checkov for Terraform](https://www.checkov.io/)
- [OpenTofu Documentation](https://opentofu.org/)

---

## Changelog

| Date | Author | Changes |
| :--- | :--- | :--- |
| 2026-07-21 | Mariano Gbego | Initial draft |

---

*This ADR follows the [Nexus Azure Platform ADR Template](_template.md).*
