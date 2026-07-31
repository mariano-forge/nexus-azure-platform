# Stage 2 — Subscription Vending

> **Depends on:** Stage 0 (bootstrap) and Stage 1 (governance).
> Each `terraform apply` provisions exactly **one** subscription and stores its state in an isolated key in the shared backend.

## What it does

Reads a YAML request file from `requests/` and provisions a governed Azure subscription via the [`avm-ptn-alz-sub-vending`](https://registry.terraform.io/modules/Azure/avm-ptn-alz-sub-vending/azure/latest) AVM module.

One apply = one subscription = one isolated `.tfstate` file. A failure on one subscription never affects others.

## Triggering a vending request

Subscription requests come from the Backstage self-service portal (see [backstage/catalog/templates/subscription-vending.yaml](../../../backstage/catalog/templates/subscription-vending.yaml)).

The scaffolder opens a PR that adds a YAML file to `requests/`. The PR workflow:

1. `sub-vending.yml` posts a `terraform plan` as a PR comment for each changed YAML.
2. `platform-team` reviews and approves (enforced by [CODEOWNERS](../../../.github/CODEOWNERS)).
3. Merge triggers `terraform apply` — one parallel job per changed subscription file.

## Request file format

```yaml
# requests/<alias>.yaml — file name is the subscription alias (must be tenant-unique)

subscription_display_name: "Project Phoenix - Dev"
subscription_management_group_id: mariano-forge-landingzones-corp
subscription_workload: DevTest   # DevTest | Production

# All fields below are optional — defaults apply
location: francecentral
subscription_alias_enabled: true
subscription_update_existing: false
subscription_tags:
  environment: dev
  costCenter: CC-1234
  owner: dev@example.com
  application: project-phoenix

# Optional: pre-create resource groups
resource_group_creation_enabled: false
resource_groups: {}

# Optional: RBAC assignments on the new subscription
role_assignment_enabled: false
role_assignments: {}

# Optional: budget alert
budget_enabled: false
budgets: {}

# Optional: register resource providers
subscription_register_resource_providers_enabled: false
subscription_register_resource_providers_and_features: {}

# Optional: User-Assigned Managed Identities
user_managed_identities: {}
```

See `requests/_example.yaml` for a minimal working example.

## Running manually

```powershell
cd terraform/stages/2-sub-vending

# 1. Init — pass the subscription name as the backend key
terraform init -backend-config="key=subscriptions/corp-prod.tfstate"

# 2. Plan
terraform plan `
  -var="subscription_name=corp-prod" `
  -var="default_billing_scope=/providers/Microsoft.Billing/billingAccounts/.../enrollmentAccounts/..."

# 3. Apply
terraform apply `
  -var="subscription_name=corp-prod" `
  -var="default_billing_scope=..."
```

## Required CI secrets

| Secret | Description |
| --- | --- |
| `AZURE_CLIENT_ID` | Service principal or managed identity client ID (OIDC) |
| `AZURE_TENANT_ID` | Entra ID tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Subscription hosting the Terraform state storage account |
| `BILLING_SCOPE` | EA/MCA/MPA billing scope used to create subscriptions |

## Variables

| Name | Default | Description |
| --- | --- | --- |
| `subscription_name` | — | YAML filename (without `.yaml`) in `requests/` |
| `default_billing_scope` | `null` | Billing scope; overridable per request via `subscription_billing_scope` |
| `default_location` | `francecentral` | Azure region; overridable per request via `location` |
| `enable_telemetry` | `false` | AVM telemetry toggle |

## Outputs

| Name | Description |
| --- | --- |
| `subscription_id` | ID of the vended subscription |
| `subscription_resource_id` | ARM resource ID |
| `resource_group_resource_ids` | Map of created resource groups |
| `management_group_subscription_association_id` | MG association ID |
| `budget_resource_ids` | Map of created budgets |
| `umi_resource_ids` | Map of created User-Assigned Managed Identities |
