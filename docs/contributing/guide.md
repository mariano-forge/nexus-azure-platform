# Contributing to Nexus Azure Platform

This is currently a solo portfolio project, built in public and documented with the same rigor as a production platform. It isn't actively seeking contributors, but the project is open under Apache 2.0 and issues/discussions are genuinely welcome if something is unclear, broken, or worth debating.

---

## Before opening an issue or PR

- Read the [README](https://github.com/mariano-forge/nexus-azure-platform#readme) for current project status — some parts of the roadmap are design-only (see [Roadmap → Beyond this repo](../roadmap.md)), not implemented yet.
- Check existing [ADRs](../adr/index.md) — if your suggestion touches a decision already documented there, reference it.

---

## Reporting a bug

Open an issue with:

- A clear description and steps to reproduce
- Expected vs actual behavior
- Relevant logs, if any

---

## Proposing a change

For anything beyond a typo or small fix — a new module, a changed networking topology, a new tool in the pipeline — please write an ADR first:

1. Copy the [ADR template](../adr/_template.md) to `docs/adr/NNN-short-description.md`.
2. Fill in Context, Decision, Rationale, Consequences, Alternatives Considered, and When to Reconsider.
3. Update the [ADR index](../adr/index.md).
4. Reference the ADR in your PR.

This is the one rule that matters most here — the project's value is as much in the documented reasoning as in the code.

---

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/):

```text
feat(terraform): add hub-spoke networking module
docs(adr): add ADR-009
fix(pipeline): correct Checkov config path
```

---

## Before opening a PR

Run locally:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

CI will additionally run Super Linter, tfsec, Checkov, Trivy, and Gitleaks — all must pass. A manual approval is required before merge on protected paths.

---

## Security issues

Please don't open a public issue for a suspected vulnerability. Email [gbegomariano@gmail.com](mailto:gbegomariano@gmail.com) with a description, reproduction steps, and impact — I'll get back to you as soon as I can (no fixed SLA at this stage, given this is a solo-maintained project).

---

## License

By contributing, you agree your contribution is licensed under the Apache License 2.0.

---

*Mariano Gbego*
