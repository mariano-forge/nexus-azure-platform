# Stage 3 — Connectivity

> **Depends on:** Stage 0 (bootstrap), Stage 1 (governance).
> Provisions the hub VNet, NSGs, and optionally Azure Firewall, Bastion, VPN Gateway, and Private DNS Zones. All optional features are disabled by default.

## What it creates

### Always deployed

| Resource | Name pattern | Purpose |
| --- | --- | --- |
| Resource Group | `rg-<prefix>-connectivity` | Holds all connectivity resources |
| Hub VNet | `vnet-hub-<prefix>-<location>` | Hub network — `10.0.0.0/16` default |
| NSG — shared | `nsg-<prefix>-shared` | Deny-all + explicit allow rules for `snet-shared` |
| NSG — private endpoints | `nsg-<prefix>-private-endpoints` | Deny-all + allow rules for `snet-private-endpoints` |

### Subnet layout (default `10.0.0.0/16`)

| Subnet | CIDR | Managed by | Purpose |
| --- | --- | --- | --- |
| `GatewaySubnet` | `10.0.0.0/27` | AVM module (when VPN enabled) | VPN/ExpressRoute — no NSG (Azure requirement) |
| `AzureBastionSubnet` | `10.0.0.64/26` | AVM module (when Bastion enabled) | Bastion — no NSG (Azure requirement) |
| `AzureFirewallSubnet` | `10.0.1.0/26` | AVM module (when Firewall enabled) | Firewall — explicit CIDR to avoid auto-allocator conflicts |
| `AzureFirewallManagementSubnet` | `10.0.1.64/26` | AVM module (when Firewall enabled) | Firewall management — explicit CIDR |
| `snet-shared` | `10.0.2.0/24` | This stage | Platform shared services |
| `snet-private-endpoints` | `10.0.3.0/24` | This stage | All platform Private Endpoints |

### Optional features (disabled by default)

| Variable | Default | Resource created |
| --- | --- | --- |
| `firewall_enabled` | `false` | Azure Firewall + route tables (~300€/month) |
| `bastion_enabled` | `false` | Azure Bastion (~70€/month with `bastion_sku = "Basic"`) |
| `vpn_gateway_enabled` | `false` | VPN Gateway (~25€/month with `vpn_gateway_sku = "Basic"`) |
| `private_dns_zones_enabled` | `false` | ~250 ALZ Private Link DNS zones (~50€/month) |

## Prerequisites

1. **Stage `0-bootstrap` applied** — provides the remote backend.
2. **Stage `1-governance` applied** — provides the management group hierarchy.
3. **Azure CLI** authenticated with `Owner` on the connectivity subscription:

   ```powershell
   az login
   az account set --subscription "<subscription-id>"
   ```

4. **Terraform ≥ 1.13** installed locally.

## Activate the remote backend

Uncomment the `backend "azurerm"` block in [terraform.tf](terraform.tf) using `0-bootstrap` outputs:

```powershell
cd ../0-bootstrap
terraform output -json
```

```hcl
backend "azurerm" {
  resource_group_name  = "<output: resource_group_name>"
  storage_account_name = "<output: storage_account_name>"
  container_name       = "cntnr-tfstate"
  key                  = "connectivity.terraform.tfstate"
}
```

Then run:

```powershell
terraform init -reconfigure
```

## Usage

```powershell
cd terraform/stages/3-connectivity

# 1. Copy and fill in the variables
cp terraform.tfvars.example terraform.tfvars
#    Set prefix, location, hub_address_space

# 2. Init with remote backend
terraform init

# 3. Review
terraform plan -out=tfplan

# 4. Apply
terraform apply tfplan
```

## Enabling optional features

Uncomment and set the relevant variables in `terraform.tfvars`:

```hcl
# Firewall
firewall_enabled  = true
firewall_sku_tier = "Standard"   # or "Basic" (requires firewall_policy too)

# Bastion
bastion_enabled = true
bastion_sku     = "Basic"        # or "Standard"

# VPN Gateway
vpn_gateway_enabled = true
vpn_gateway_sku     = "Basic"    # deprecated; use "VpnGw1" for production

# Private DNS Zones (full ALZ set — ~250 zones)
private_dns_zones_enabled = true
```

## Outputs

| Output | Description | Consumed by |
| --- | --- | --- |
| `hub_vnet_id` | Resource ID of the hub VNet | Spoke peering, Private Endpoints |
| `hub_vnet_name` | Name of the hub VNet | Diagnostic settings |
| `subnet_ids` | Map of subnet name → resource ID | NSG associations, Private Endpoints |
| `private_dns_zone_ids` | Map of DNS zone name → resource ID (when enabled) | Private Endpoint DNS config |
| `resource_group_name` | Name of the connectivity resource group | Cross-stage references |

---

## Troubleshooting

### `NetcfgSubnetRangesOverlap` — AzureFirewallSubnet

**Symptom:**

```plaintext
Error: NetcfgSubnetRangesOverlap — Subnet 'AzureFirewallSubnet' overlaps with an existing subnet.
```

**Cause:** The AVM module (`avm-ptn-alz-connectivity-hub-and-spoke-vnet ~> 0.17`) auto-calculates firewall subnet CIDRs using `cidrsubnets()` from the hub address space.
When `default_hub_address_space` is not explicitly set, the module defaults to `10.0.0.0/16` and allocates subnets sequentially — without knowing about custom subnets already defined.
This causes `AzureFirewallSubnet` to collide with `AzureBastionSubnet` (both end up at `10.0.0.64/26`).

**Fix:** Provide explicit CIDRs in the `firewall` block to bypass the auto-allocator:

```hcl
firewall = {
  sku_tier                         = var.firewall_sku_tier
  subnet_address_prefix            = cidrsubnet(var.hub_address_space, 10, 4) # 10.0.1.0/26
  management_subnet_address_prefix = cidrsubnet(var.hub_address_space, 10, 5) # 10.0.1.64/26
}
```

---

### `NetcfgSubnetRangesOverlap` — orphaned `AzureFirewallManagementSubnet`

**Symptom:** After a failed apply with `firewall = true`, re-applying fails because `AzureFirewallManagementSubnet` was created in a previous partial run and now conflicts with the `AzureFirewallSubnet` being created.

**Diagnosis:**

```powershell
az network vnet show --name <vnet-name> --resource-group <rg> \
  --query "subnets[].{name:name, cidrs:addressPrefixes}" -o table
```

**Fix:** Destroy the hub module and recreate cleanly:

```powershell
terraform destroy -target="module.hub_and_spoke"
terraform apply
```

---

### `AzfwAddToFirewallPolicyFailed` — Firewall SKU mismatch

**Symptom:**

```plaintext
Azure Firewall failed to reference Firewall Policy — AzfwAddToFirewallPolicyFailed
```

**Cause:** `firewall_sku_tier = "Basic"` requires a Firewall Policy of SKU "Basic". When `firewall_policy = false` in `enabled_resources`, the module creates a Standard policy by default — which cannot attach to a Basic firewall.

**Fix:** Either use `firewall_sku_tier = "Standard"` (no policy required), or enable `firewall_policy = true` and add `firewall_policy = { sku = "Basic" }`. This is handled automatically by the `firewall_sku_tier` variable in this stage.

---

### `Invalid value for variable` — Bastion Developer SKU

**Symptom:**

```plaintext
The virtual network ID is required for the Developer SKU (Only).
The IP configuration is not required for the Developer SKU.
The Developer SKU does not support availability zones.
```

**Cause:** The AVM module `~> 0.17` unconditionally injects `ip_configuration` and `zones` into the Bastion resource, both of which are forbidden for the Developer SKU.

**Fix:** Use `bastion_sku = "Basic"` instead. The Developer SKU is not supported by this module version.

---

### Duplicate subnets — `GatewaySubnet` / `AzureBastionSubnet`

**Symptom:** When enabling `bastion = true` or `vpn_gateway = true`, Terraform plans to create NEW `GatewaySubnet` and `AzureBastionSubnet` with different CIDRs than the ones already in the VNet.

**Cause:** The module manages its own version of these subnets independently from user-defined subnets. Azure does not allow two subnets with the same name in a VNet.

**Fix:** Remove `GatewaySubnet` and `AzureBastionSubnet` from the `subnets` map and instead provide their CIDRs in the respective feature config blocks:

```hcl
bastion = {
  sku                   = var.bastion_sku
  subnet_address_prefix = local.snet_bastion  # hands subnet management to the module
}

virtual_network_gateways = {
  subnet_address_prefix = local.snet_gateway  # hands subnet management to the module
  vpn                   = { sku = var.vpn_gateway_sku }
}
```
