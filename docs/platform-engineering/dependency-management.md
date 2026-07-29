# Dependency Management

Reusable modules are wrapped **Azure Verified Modules (AVM)**, with every version pinned explicitly — no floating versions in `terraform` source blocks.

## Strategy

Version bumps are surfaced automatically by **Dependabot**, configured in `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "terraform"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "terraform"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

Dependabot opens a PR for each new AVM module, provider, or GitHub Actions version. That PR goes through the same `pr-validation.yml` pipeline (`terraform plan`, tfsec, Checkov) as any other change — followed by manual review and merge.

See [ADR-011](../adr/011-dependency-management-strategy.md) for the full rationale, including the comparison against Renovate.

---

## Trade-offs accepted

!!! warning "No automated smoke tests on version bumps"
    Dependabot validates a version bump with `terraform plan` plus manual review only — not with an actual deployment. This is an accepted limitation for now, consistent with the dry-run-first approach documented in [ADR-010](../adr/010-terraform-bootstrap-strategy.md).

- Less configurable than Renovate for grouping multiple updates into one PR — acceptable given the small number of tracked dependencies at this stage.
- If PR volume from Dependabot becomes noisy (many AVM modules bumping independently), Renovate's grouping rules would justify the extra configuration effort.

---

## Security updates

Dependabot Security Updates (CVE-triggered PRs) are enabled separately in repository settings, independent of the weekly schedule above. These PRs are not bound to the weekly cadence — they open as soon as a CVE is published against a tracked dependency.
