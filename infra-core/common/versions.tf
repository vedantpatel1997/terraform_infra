terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.9.0"
    }
  }

  backend "azurerm" {
    # Backend settings are supplied via `terraform init -backend-config=backend.tfvars`.
    # Copy `backend.tfvars.example` to `backend.tfvars` and populate the values
    # before running `terraform init`.
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  auxiliary_tenant_ids = [
    var.hub_tenant_id,
  ]
}

provider "azurerm" {
  alias = "hub"
  features {}

  subscription_id = var.hub_subscription_id
  tenant_id       = var.hub_tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  auxiliary_tenant_ids = [
    var.tenant_id,
  ]
}
