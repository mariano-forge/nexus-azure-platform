# Stage 4 — Observability

> **Depends on:** Stage 0 (bootstrap), Stage 1 (governance), Stage 3 (connectivity).
> Provisions the centralized observability foundation: Log Analytics Workspace, Automation Account, and Data Collection Rules.

## What it creates

| Resource | Name pattern | Purpose |
| --- | --- | --- |
| Resource Group | `rg-<prefix>-management` | Holds all observability resources |
| Log Analytics Workspace | `law-<prefix>-platform` | Central sink for all platform logs — 30-day retention (cost default) |
| Automation Account | `aa-<prefix>-platform` | Runs the M3 auto-remediation runbooks |
| User-assigned Managed Identity | `uami-ama` | Used by Azure Monitor Agent to authenticate to the LAW |
| Data Collection Rule | `dcr-change-tracking` | Tracks file and registry changes on VMs |
| Data Collection Rule | `dcr-vm-insights` | Collects performance counters for VM Insights |
| Log Analytics Solutions | configurable via `log_analytics_solution_plans` | e.g. SecurityInsights, Updates |

> `dcr-defender-sql` is intentionally disabled — requires Microsoft Defender for SQL, out of MVP scope.

## Prerequisites

1. **Stage `0-bootstrap` applied** — provides the remote backend and pipeline Key Vault.
2. **Stage `1-governance` applied** — management subscription must be placed under the correct management group.
3. **Azure CLI** authenticated with `Owner` on the management subscription:

   ```powershell
   az login
   az account set --subscription "<management-subscription-id>"
   ```

4. **Terraform ≥ 1.13** installed locally.

## Activate the remote backend

Uncomment the `backend "azurerm"` block in [terraform.tf](terraform.tf) and fill in the values from `0-bootstrap` outputs:

```powershell
cd ../0-bootstrap
terraform output -json
```

```hcl
backend "azurerm" {
  resource_group_name  = "<output: resource_group_name>"
  storage_account_name = "<output: storage_account_name>"
  container_name       = "cntnr-tfstate"
  key                  = "observability.terraform.tfstate"
}
```

Then run:

```powershell
terraform init -reconfigure
```

## Usage

```powershell
cd terraform/stages/4-observability

# 1. Copy and fill in the variables
cp terraform.tfvars.example terraform.tfvars

# 2. Init with remote backend
terraform init

# 3. Review
terraform plan -out=tfplan

# 4. Apply
terraform apply tfplan
```

## After apply — wire diagnostic settings

The LAW ID output from this stage is consumed by the other stages to send their diagnostic logs to the central workspace:

```powershell
terraform output -json
```

| Output | Consumed by |
| --- | --- |
| `log_analytics_workspace_id` | Diagnostic settings on Key Vault (stage 0), hub VNet (stage 3) |
| `automation_account_id` | Runbook resources (M3 auto-restart) |

Pass the LAW ID as a variable when adding diagnostic settings to stages 0 and 3.
