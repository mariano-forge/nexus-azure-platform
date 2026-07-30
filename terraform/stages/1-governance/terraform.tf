# Terraform and provider configuration
terraform {
  required_version = ">= 1.13, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.8"
    }
    alz = {
      source  = "azure/alz"
      version = "~> 0.21"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
  }

  # Remote backend — uncomment and fill in after running stage 0-bootstrap.
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "sttfstate"
  #   container_name       = "tfstate"
  #   key                  = "alz.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}

provider "alz" {
  library_overwrite_enabled = true
  library_references = [
    {
      path = "platform/alz"
      ref  = "2026.04.2"
    },
    {
      custom_url = "${path.root}/lib"
    }
  ]
}
