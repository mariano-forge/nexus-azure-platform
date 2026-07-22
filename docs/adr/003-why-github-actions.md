# ADR-003: Why GitHub Actions over Azure DevOps?

**Status:** ✅ Accepted  
**Date:** 2026-07-21  
**Author:** Mariano Gbego  
**Context:** Nexus Azure Platform

---

## Context

We need a CI/CD orchestrator for the Nexus Azure Platform. The platform requires:
- Infrastructure as Code validation (Terraform fmt, validate, plan)
- Security scanning (tfsec, Checkov, Trivy, Gitleaks)
- Manual approval gates before production apply
- Integration with Backstage (via Scaffolder)
- Cost management and visibility

The two primary candidates on Azure are **GitHub Actions** and **Azure DevOps**.

---

## Decision

We will use **GitHub Actions**.

---

## Rationale

| Criteria | GitHub Actions | Azure DevOps |
| :--- | :--- | :--- |
| **Native Integration** | ✅ Code lives on GitHub. Actions are built-in, no extra service to manage. | ⚠️ Requires linking a separate Azure DevOps project. Adds overhead. |
| **Open-Source Ecosystem** | ✅ Massive marketplace with community actions (tfsec, Checkov, etc.). | ⚠️ Marketplace exists but is more enterprise-focused and less community-driven. |
| **Cost** | ✅ Free for public repositories. Unlimited minutes on public repos. | ⚠️ Free for up to 5 users, but parallel jobs and self-hosted agents often incur costs. |
| **Backstage Integration** | ✅ Backstage Scaffolder natively supports GitHub Actions via its `github:actions` plugin. | ❌ Requires custom API integrations. |
| **Security** | ✅ Native secret management, OIDC integration with Azure (no static credentials). | ⚠️ Supports OIDC, but often relies on Service Connections with secrets. |
| **Developer Experience** | ✅ YAML-based workflows stored alongside code. Familiar to developers. | ⚠️ Classic pipelines or YAML, but historically more complex. |

---

## Consequences

### Positive
- **Single source of truth**: Code, issues, and pipelines are all in one place (GitHub).
- **Open-source friendly**: Contributors don't need an Azure DevOps account; they just fork the repo.
- **Modern standard**: GitHub Actions is the de-facto standard for open-source cloud projects (Kubernetes, Terraform itself use it).

### Negative
- **Azure-native features**: Azure DevOps has deeper integration with some Azure PaaS services (e.g., Azure Boards, Azure Test Plans) which we don't use.
- **Parallelism limits**: Free tier has limited parallelism, but for a single pipeline, this is not an issue.

---

## When to reconsider

- If the platform moves to self-hosted runners at scale (re-evaluate Azure DevOps self-hosted agents pricing).
- If the organization adopts Azure DevOps as a company-wide standard (prefer consistency over tooling preference).

---

## Alternatives Considered

1. **Azure DevOps**  
   - *Why rejected?* Requires managing a separate project and discourages external contributors.

2. **Jenkins**  
   - *Why rejected?* Maintenance overhead (plugins, JVM, security patches) not justified for this use case.

3. **GitLab CI**  
   - *Why rejected?* Not considered as the code is hosted on GitHub.

---

## Related ADRs

- [ADR-001](001-why-terraform.md) : GitHub Actions will run all Terraform validation and deployment workflows.
- [ADR-005](005-why-backstage.md) : Backstage requires GitHub integration, reinforcing this choice.

---

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform GitHub Actions Guide](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
- [Backstage GitHub Actions Plugin](https://backstage.io/docs/features/software-templates/writing-templates)

---

## Changelog

| Date | Author | Changes |
| :--- | :--- | :--- |
| 2026-07-21 | Mariano Gbego | Initial draft |

---

*This ADR follows the [Nexus Azure Platform ADR Template](_template.md).*
