# Stage 0 — Bootstrap

> **Run this once before any other stage.**
> This is the only stage that uses **local Terraform state** — by design (see [ADR-010](../../../docs/adr/010-terraform-bootstrap-strategy.md)).

## What it creates

| Resource | Name pattern | Purpose |
| --- | --- | --- |
| Resource Group | `rg-<prefix>-tfstate` | Holds all bootstrap resources |
| Storage Account | `st<prefix>tf<random6>` | Remote backend for every subsequent stage |
| Blob container | `tfstate` | One `.tfstate` file per stage, keyed by stage name |
| Key Vault | `kv-<prefix>-pipeline` | Pipeline credentials — Terraform SP, GitHub token (see [ADR-009](../../../docs/adr/009-key-vault-separation.md)) |

The bootstrap's own state file stays **local** and is never pushed to remote storage. Treat it as read-only once the platform is up.

## Prerequisites

1. **Azure account** with an active subscription.
2. **Elevated Tenant Root access** — required to create Management Groups in Stage 1:
   - Go to **Entra ID → Properties → Access management for Azure resources** and set the toggle to **Yes**.
3. **Azure CLI** authenticated as an account that has `Owner` on the target subscription:

   ```powershell
   az login
   az account set --subscription "<subscription-id>"
   ```

4. **Terraform ≥ 1.13** installed locally.

## Usage

```powershell
cd terraform/stages/0-bootstrap

# 1. Copy and fill in the variables
cp terraform.tfvars.example terraform.tfvars
#    Edit subscription_id (and optionally prefix / location)

# 2. Init — local backend, no config needed
terraform init

# 3. Review — save plan to file so apply uses exactly what was reviewed
terraform plan -out=tfplan

# 4. Apply
terraform apply tfplan
```

## After apply — wire Stage 1

Copy the outputs into `terraform/stages/1-governance/terraform.tf` to activate the remote backend:

```powershell
terraform output -json
```

Then uncomment and fill in the backend block:

```hcl
# terraform/stages/1-governance/terraform.tf
backend "azurerm" {
  resource_group_name  = "<output: resource_group_name>"
  storage_account_name = "<output: storage_account_name>"
  container_name       = "tfstate"
  key                  = "1-governance.tfstate"
}
```

Run `terraform init -reconfigure` inside `1-governance/` to migrate to the remote backend.

Each subsequent stage uses the **same Storage Account** with a different `key`:

| Stage | `key` |
| --- | --- |
| 1-governance | `1-governance.tfstate` |
| 2-connectivity | `2-connectivity.tfstate` |
| 3-security | `3-security.tfstate` |

## Secrets — populate the Key Vault

After apply, store the CI/CD credentials in the pipeline Key Vault:

```powershell
KV=$(terraform output -raw key_vault_name)

# Service Principal used by GitHub Actions
az keyvault secret set --vault-name $KV --name "terraform-client-id"     --value "<sp-app-id>"
az keyvault secret set --vault-name $KV --name "terraform-client-secret" --value "<sp-password>"
az keyvault secret set --vault-name $KV --name "terraform-tenant-id"     --value "<tenant-id>"
az keyvault secret set --vault-name $KV --name "terraform-subscription-id" --value "<subscription-id>"
```

These secrets are consumed by the GitHub Actions workflow via the `azure/get-keyvault-secrets` action.

## Destroy

```powershell
terraform plan -destroy -out=tfplan-destroy
terraform apply tfplan-destroy
```

> The Key Vault has `purge_protection_enabled = false`, so it can be hard-deleted immediately. The local state file is the only artifact that must be deleted manually afterward.
