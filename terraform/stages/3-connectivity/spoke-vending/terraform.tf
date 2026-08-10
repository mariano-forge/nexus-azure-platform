terraform {
  required_version = ">= 1.13, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
      # azurerm.hub is used for hub-side peering and optional DNS zone links.
      configuration_aliases = [azurerm.hub]
    }
  }

  # Each spoke has an isolated state file keyed by its alias.
  # backend "azurerm" {
  #   resource_group_name  = "rg-nexus-tfstate"
  #   storage_account_name = "stnexustfstate"
  #   container_name       = "cntnr-tfstate"
  #   key                  = "connectivity/spokes/<alias>.terraform.tfstate"
  # }
}

# Default provider — targets the workload subscription (spoke lives here).
provider "azurerm" {
  subscription_id = var.workload_subscription_id
  features {}
}

# Hub provider — targets the connectivity subscription (hub peering and DNS links).
provider "azurerm" {
  alias           = "hub"
  subscription_id = var.hub_subscription_id
  features {}
}
