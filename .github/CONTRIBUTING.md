# Contributing to Nexus Azure Platform

Nexus Azure Platform is built in public, documented with intent, and open to contributors who care about production-grade cloud infrastructure.

We welcome contributions of all kinds — whether it's fixing a typo in the docs, reporting a bug, suggesting a new feature, or adding a new Terraform module.

---

## 📖 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Commit Messages](#commit-messages)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Architecture Decision Records (ADR)](#architecture-decision-records-adr)
- [Security Reporting](#security-reporting)
- [Getting Help](#getting-help)
- [License](#license)

---

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code. Please report unacceptable behavior to gbegomariano@gmail.com.

---

## How to Contribute

### I don't know where to start!
- Check our [`good first issue`](https://github.com/mariano-gbego/nexus-azure-platform/labels/good%20first%20issue) label for beginner-friendly tasks.
- Read the [documentation](docs/) to understand the platform architecture.
- Join the discussion in the Issues section.

### I found a bug!
Please open an issue using the **Bug Report** template and include:
- A clear title and description.
- Steps to reproduce the issue.
- Expected vs actual behavior.
- Screenshots or logs if applicable.

### I want to suggest a feature!
Open an issue with the **Feature Request** label and describe:
- The problem you're trying to solve.
- Your proposed solution.
- Any alternatives you've considered.

---

## Development Workflow

We use **GitHub Flow** for collaboration:

1. **Fork** the repository (if you're an external contributor).
2. **Clone** your fork locally.
3. Create a **new branch** for your work:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. Commit your changes (see [Commit Messages](#commit-messages) below).
5. Push your branch to your fork.
6. Open a Pull Request against the `main` branch of this repository.

> 💡 **Internal contributors:** You can create branches directly in the main repository.

---

## Commit Messages

We follow the [Conventional Commits](https://www.conventionalcommits.org/) format to keep the history clean and enable automated changelog generation.

**Format:**
```text
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

**Types:**

| Type | Description |
| :--- | :--- |
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation updates (README, ADRs, guides) |
| `refactor` | Code refactoring (no functional changes) |
| `test` | Adding or updating tests |
| `ci` | CI/CD pipeline changes |
| `security` | Security fixes or improvements |
| `adr` | New or updated Architecture Decision Record |

**Examples:**
```bash
# Good
git commit -m "feat(terraform): add module for Hub & Spoke networking"
git commit -m "docs(adr): add ADR-005 for Backstage selection"
git commit -m "ci(pipeline): add tfsec scanning to PR workflow"

# Linking issues:
git commit -m "feat(terraform): add AKS module with Workload Identity

This adds a reusable module for AKS clusters with Workload Identity enabled.
Closes #12"
```

Always link your commits to an issue using `Closes #<issue-number>` when applicable.

---

## Coding Standards

### Terraform (HCL)
- Run `terraform fmt` on all `.tf` files before committing.
- Organize modules with the following structure:
  ```text
  module/
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  └── README.md
  ```
- Use variables for all configurable parameters. No hard-coded values.
- Prefer remote state backends (Azure Storage) for all environments.
- Follow the [Terraform Best Practices](https://developer.hashicorp.com/terraform/language/style).

### GitHub Actions (YAML)
- Use `snake_case` for workflow names.
- Pin actions to specific commit hashes (for security) or major version tags.
- Keep workflows modular: split `pr-validation.yml` and `deploy.yml`.

### Documentation (MkDocs)
- Write in Markdown.
- Use ADRs for architecture decisions.
- Update the `docs/` folder when adding new features.

---

## Pull Request Process

- **One feature/fix per PR** — keep PRs focused and reviewable.
- Run all checks locally before pushing:
  - `terraform fmt`
  - `terraform validate`
  - `terraform plan` (ensure it runs without errors)
  - `tfsec` and `checkov` locally if possible
- Link your PR to an issue using `Closes #<issue>` in the PR description.
- Assign labels to your PR (e.g., `area/terraform`, `type/feature`).
- Wait for CI — all GitHub Actions checks must pass:
  - Lint
  - Terraform validate
  - Security scanning (tfsec, Checkov, Trivy)
  - OPA/Conftest
  - Plan
- **Manual Approval** is required for changes that modify the `main` branch (enforced by branch protection rules).
- Once approved, the PR will be **squashed and merged** to keep the history clean.

---

## Architecture Decision Records (ADR)

This is the most important rule for contributors.

If you are proposing a significant architectural change (e.g., adding a new cloud provider, changing the networking topology, introducing a new tool), you **MUST** write an ADR.

1. Copy the [ADR template](docs/adr/_template.md) to `docs/adr/NNN-short-description.md`.
2. Fill in **all sections**: Context, Decision, Rationale, Consequences, When to reconsider, Alternatives.
3. Update the [ADR index](docs/adr/index.md) with the new entry.
4. Link the ADR in the Pull Request.

> **Why?** The Nexus Azure Platform is not just about *what* we build, but *why* we build it. ADRs ensure we have a permanent record of architectural reasoning.

---

## Security Reporting

If you discover a security vulnerability, please **do NOT open a public issue**.

Instead, send an email to **gbegomariano@gmail.com** with:
- A clear description of the vulnerability.
- Steps to reproduce it.
- The potential impact.

We will respond within **48 hours**.

---

## Getting Help

- Open an [Issue](https://github.com/mariano-gbego/nexus-azure-platform/issues) for questions.
- Tag the maintainers listed in [CODEOWNERS](.github/CODEOWNERS).
- Review existing [ADRs](docs/adr/) to understand past decisions.

---

## License

By contributing to this project, you agree that your contributions will be licensed under the **Apache License 2.0**.

---

*Built with intention. Documented with care. Secured by design.*

— Mariano Gbego, Platform Engineer
