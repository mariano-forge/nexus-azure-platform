terraform {
  required_version = ">= 1.13, < 2.0"

  required_providers {
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
      version = "~> 3.6"
    }
  }

  # backend "azurerm" {
  #   resource_group_name  = "rg-nexus-tfstate"
  #   storage_account_name = "stnexustfstate"
  #   container_name       = "cntnr-tfstate"
  #   key                  = "platform.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}
