data "azurerm_client_config" "current" {}

# Random suffix to guarantee global uniqueness of the Storage Account name
resource "random_string" "sa_suffix" {
  length  = 6
  upper   = false
  special = false
}

# ── Resource Group ────────────────────────────────────────────────────────────
module "rg_tfstate" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.4.0"

  name             = "rg-${var.prefix}-tfstate"
  location         = var.location
  enable_telemetry = false
  tags             = var.tags
}

# ── Storage Account (Terraform backend) ──────────────────────────────────────
module "st_tfbackend" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.7.4"

  name      = "st${var.prefix}tf${random_string.sa_suffix.result}"
  location  = var.location
  parent_id = module.rg_tfstate.resource_id

  account_sku_name = "Standard_LRS" # LRS is sufficient for Terraform state
  # shared_access_key_enabled = false is the AVM default — Entra ID access only

  containers = {
    tfstate = {
      name = "cntnr-tfstate"
    }
  }

  enable_telemetry = false
  tags             = var.tags
}

# ── Key Vault pipeline (kv-platform-pipeline) ────────────────────────────────
module "kv_pipeline" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.2"

  name                = "kv-${var.prefix}-pipeline"
  location            = var.location
  resource_group_name = module.rg_tfstate.name
  tenant_id           = var.tenant_id != null ? var.tenant_id : data.azurerm_client_config.current.tenant_id

  sku_name                 = "standard"
  purge_protection_enabled = false # bootstrap is recreatable — purge protection not needed

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Allow" # no VNet at bootstrap stage — restrict after Stage 1
  }

  # The caller identity (person running the bootstrap) is granted Key Vault Administrator
  role_assignments = {
    bootstrap_operator = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = var.principal_id != null ? var.principal_id : data.azurerm_client_config.current.object_id
      principal_type             = var.principal_type
    }
  }

  enable_telemetry = false
  tags             = var.tags
}
