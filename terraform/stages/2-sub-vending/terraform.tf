terraform {
  required_version = ">= 1.13, < 2.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Key injected at init time: -backend-config="key=subscriptions/<name>.tfstate"
  backend "azurerm" {
    resource_group_name  = "rg-nexus-tfstate"
    storage_account_name = "stnexustfstate"
    container_name       = "cntnr-tfstate"
  }
}

# Credentials via ARM_* env vars or ARM_USE_OIDC=true (Workload Identity).
provider "azapi" {}

provider "azurerm" {
  features {}
}
