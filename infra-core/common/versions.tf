terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.9.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "TerraformStorageAccount"
    storage_account_name = "terrsaform"
    container_name       = "terraform"
    key                  = "infra-core-common.tfstate"

    # Use the same service principal credentials as the providers so the
    # remote state storage account is accessed with the shared identity.
    use_azuread_auth = true
    subscription_id  = var.subscription_id
    tenant_id        = var.tenant_id
    client_id        = var.client_id
    client_secret    = var.client_secret
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
