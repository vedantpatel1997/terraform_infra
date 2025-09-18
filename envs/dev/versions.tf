terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.9.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.12.0"
    }
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
  client_id       = var.spoke_client_id
  client_secret   = var.spoke_client_secret
}

provider "azurerm" {
  alias = "hub"

  features {}

  subscription_id = var.hub_subscription_id
  tenant_id       = var.hub_tenant_id
  client_id       = var.hub_client_id
  client_secret   = var.hub_client_secret
}

provider "azapi" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.spoke_client_id
  client_secret   = var.spoke_client_secret
}

provider "azapi" {
  alias = "hub"

  subscription_id = var.hub_subscription_id
  tenant_id       = var.hub_tenant_id
  client_id       = var.hub_client_id
  client_secret   = var.hub_client_secret
}
