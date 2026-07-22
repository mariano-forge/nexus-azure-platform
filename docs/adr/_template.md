# ADR-NNN: [TITLE]
**Status:** [Draft | Proposed | Accepted | Deprecated | Superseded]  
**Date:** YYYY-MM-DD  
**Author:** [Your Name]  
**Context:** Nexus Azure Platform

---

## Context

Describe the architectural context and the problem that needs to be solved.

- What is the current situation?
- What are the constraints or forces at play?
- What are the business or technical drivers?

> **Example:**  
> We need a CI/CD orchestrator for the Nexus Azure Platform. The platform requires IaC validation, security scanning, manual approval gates, and integration with Backstage.

---

## Decision

State the decision that was made. Be clear and unambiguous.

> **Example:**  
> We will use **GitHub Actions**.

---

## Rationale

Explain why this decision was made. Provide evidence and reasoning.

| Criteria | Option A | Option B | Option C |
| :--- | :--- | :--- | :--- |
| **Criteria 1** | ✅ | ❌ | ⚠️ |
| **Criteria 2** | ... | ... | ... |

> **Example:**  
> | Criteria | GitHub Actions | Azure DevOps |
> | :--- | :--- | :--- |
> | **Native Integration** | ✅ Code and pipelines in one place | ❌ Requires separate project |
> | **Cost** | ✅ Free for public repos | ❌ Costs scale with usage |
> | **Backstage Integration** | ✅ Native plugin | ❌ Custom integration required |

---

## Consequences

### Positive
- List the positive outcomes of this decision.

### Negative
- List the trade-offs, risks, or downsides.

> **Example:**  
> **Positive:**  
> - Single source of truth (code + pipelines in one place).  
> **Negative:**  
> - Parallelism limits on the free tier.

---

## When to reconsider

Describe the conditions or triggers that would lead to revisiting this decision.

- Trigger 1 (e.g., change in scale, cost, or organizational strategy).
- Trigger 2 (e.g., a better alternative becomes available or mature).

> **Example:**  
> - If the organization adopts Azure DevOps as a company-wide standard.  
> - If self-hosted runner costs at scale make Azure DevOps more competitive.

---

## Alternatives Considered

List the alternatives that were considered and explain why they were rejected.

- **Alternative 1** : Description. *Why rejected?*  
- **Alternative 2** : Description. *Why rejected?*  

> **Example:**  
> - **Azure DevOps** : Rejected because it requires managing a separate project and discourages external contributors.  
> - **Jenkins** : Rejected due to maintenance overhead.

---

## Related ADRs

- [ADR-NNN](NNN-topic.md) : Brief description of how it relates.

---

## References

- [Link to documentation](https://example.com)
- [Link to relevant RFC or article](https://example.com)

---

## Changelog

| Date | Author | Changes |
| :--- | :--- | :--- |
| YYYY-MM-DD | [Name] | Initial draft |

---

*This ADR follows the [Nexus Azure Platform ADR Template](_template.md).*
