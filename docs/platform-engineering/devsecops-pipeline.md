# DevSecOps Pipeline

Every Pull Request to `main` triggers the following validation pipeline — [`pr-validation.yml`](https://github.com/mariano-forge/nexus-azure-platform/blob/main/.github/workflows/pr-validation.yml):

| Step | Tool | Status | Purpose |
|---|---|---|---|
| 1 | Super Linter (tflint, Markdown, YAML, JSON) | ✅ Active | Style and lint |
| 2 | Terraform `fmt` / `validate` | ✅ Active | Formatting and syntax |
| 3 | tfsec | 🚧 M1 | Fast infra security scan |
| 4 | Checkov | 🚧 M1 | Policy-as-code + CIS Benchmark mapping |
| 5 | Trivy | 🚧 M1 | Vulnerability scanning |
| 6 | Gitleaks | 🚧 M1 | Secret detection |
| ⏸ | Manual Approval | 🚧 M1 | Required before `apply` on critical environments |

!!! info "Steps 3–6 land in M1"
    The pipeline foundation (Super Linter + Terraform validation) is active today. tfsec, Checkov, Trivy, and Gitleaks scaffolding is already in `pr-validation.yml` (commented) — they will be wired up as part of M1.

---

## Design decisions

**Why tfsec AND Checkov?**

They serve distinct roles: tfsec is a fast pre-merge scan optimised for speed; Checkov provides deeper policy-as-code validation with explicit CIS Benchmark mapping. Keeping both is intentional, not redundant. See [ADR-003](../adr/003-why-github-actions.md) for the full pipeline rationale.

**Action SHA pinning**

All `uses:` references in the workflow are pinned to commit SHAs (e.g. `actions/checkout@3d3c42e5...`) rather than floating tags like `@v4`. This prevents supply-chain attacks on the pipeline itself — a tag can be silently moved to a different commit; a SHA cannot.

**Issue creation on failure**

A `create-issue-on-failure` job runs on `push` to `main` if any upstream job fails. It opens a GitHub Issue tagged `ci-failure` with run context (link, commit SHA, actor) and deduplicates if an issue with the same title is already open.

---

## Running checks locally

```bash
# Terraform formatting
terraform fmt -recursive

# Terraform validation (no backend required)
terraform -chdir=terraform/environments/dev init -backend=false
terraform -chdir=terraform/environments/dev validate

# tfsec (once M1 lands)
docker run --rm -v "$(pwd):/src" aquasec/tfsec /src

# Checkov (once M1 lands)
checkov -d terraform/

# Gitleaks (once M1 lands)
docker run --rm -v "$(pwd):/path" zricethezav/gitleaks detect --source /path
```
