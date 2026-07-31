# Stage 1 — Governance

> **Requires stage `0-bootstrap` to have been applied first.**
> The remote backend for this stage is created by `0-bootstrap`.

## What it creates

| Resource | Details |
| --- | --- |
| Management Group hierarchy | Custom `mariano-forge` architecture — root + Landing Zones, Platform, Corp, Online, Sandboxes, Management, Connectivity, Identity, Security, Decommissioned |
| ALZ policy definitions | Full enterprise-scale catalog from `platform/alz@2026.04.2` (149 definitions, 42 policy set definitions) |
| ALZ policy assignments | **All standard ALZ assignments disabled at MVP** via `creation_enabled = false` — see [ADR-013](../../../docs/adr/013-policy-catalog-vs-assignment-scope.md) |
| Custom tag-audit assignments | `Audit-Tags-Mandatory` + `Audit-Tags-Mandatory-Rg` at root — enforces `owner` and `costcenter` tags on all resources |

The management group hierarchy is driven by a static JSON file (`lib/architecture_definition/<root_id>.alz_architecture_definition.json`) that must be generated before the first `terraform plan`. See [Before first run](#before-first-run--generate-the-architecture-definition).

## Prerequisites

1. **Stage `0-bootstrap` applied** — you need its outputs:

   ```powershell
   cd ../0-bootstrap
   terraform output -json
   ```

2. **Elevated Tenant Root access** — required to create Management Groups:
   - **Entra ID → Properties → Access management for Azure resources** → toggle to **Yes**.
3. **Azure CLI** authenticated with `Owner` on the target subscription:

   ```powershell
   az login
   az account set --subscription "<subscription-id>"
   ```

4. **Terraform ≥ 1.13** installed locally.

## Before first run — generate the architecture definition

The architecture definition JSON is a static file (Terraform reads it at plan time, before variables are resolved). Run this script once, and re-run it whenever you change `root_id` or `management_groups_config`:

**Windows (PowerShell):**

```powershell
cd terraform/stages/1-governance

.\scripts\setup-lib.ps1 `
  -RootId "contoso" `
  -IncludeIdentity $true `
  -IncludeDecommissioned $false `
  -IncludeLocal $false `
  -IncludeSandboxes $true `
  -IncludeSecurity $true
```

**Linux / macOS:**

```bash
./scripts/setup-lib.sh -r contoso -i true -d false -l false -s true -e true
```

The script regenerates `lib/architecture_definition/<root_id>.alz_architecture_definition.json`. Commit the result.

> The `root_id` value passed to this script **must match** `var.root_id` in `terraform.tfvars`.

## Activate the remote backend

Fill in the `backend "azurerm"` block in [terraform.tf](terraform.tf) with the outputs from `0-bootstrap`:

```hcl
backend "azurerm" {
  resource_group_name  = "<output: resource_group_name>"
  storage_account_name = "<output: storage_account_name>"
  container_name       = "tfstate"
  key                  = "1-governance.tfstate"
}
```

Then run:

```powershell
terraform init -reconfigure
```

## Usage

```powershell
cd terraform/stages/1-governance

# 1. Copy and fill in the variables
cp terraform.tfvars.example terraform.tfvars
#    Set root_id (must match what you passed to setup-lib) and management_groups_config

# 2. Init with remote backend
terraform init

# 3. Review
terraform plan -out=tfplan

# 4. Apply
terraform apply tfplan
```

## Re-enabling ALZ policy assignments

At MVP, all standard ALZ policy assignments are disabled. To re-enable them incrementally as the platform matures, edit `locals.tf` and remove the relevant entries from `_mvp_disabled_assignments`:

```hcl
# Example: re-enable activity log diagnostic policy at root MG
(local.mg.root) = [
  # "Deploy-AzActivity-Log",   ← remove this line to re-enable
  "Deploy-ASC-Monitoring",
  ...
]
```

Suggested re-enable order by stage:

| Stage | Assignments to re-enable |
| --- | --- |
| After `2-connectivity` | `Enable-DDoS-VNET`, `Deny-Subnet-Without-Nsg`, `Deny-Public-IP-On-NIC` |
| After `3-observability` | `Deploy-MCSB2-Monitoring`, `Deploy-AzActivity-Log`, `Deploy-ASC-Monitoring`, `Deploy-Diag-LogsCat` (populate `policy_default_values` with real workspace ID) |
| After `4-security` | `Deploy-MDFC-Config-H224`, `Deploy-MDEndpoints`, `Enforce-ACSB`, `Enforce-GR-KeyVault` |

After each change, run `terraform plan -out=tfplan` and verify only the expected new assignments appear before applying.

## AVM module

| Module | Version |
| --- | --- |
| `Azure/avm-ptn-alz/azurerm` | `0.21.0` |

## Destroy

```powershell
terraform plan -destroy -out=tfplan-destroy
terraform apply tfplan-destroy
```

> Destroying this stage removes all custom management groups and policy definitions. Any subscriptions placed under these management groups will be moved to the tenant root. Re-run `setup-lib` and `terraform init` before re-applying from scratch.
