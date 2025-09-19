locals {
  default_naming_definitions = {
    rg_network = {
      purpose       = "rg-common-network"
      resource_type = "resource_group"
    }
    vnet_common = {
      purpose    = "vnet-common"
      max_length = 64
    }
    snet_private_endpoints = {
      purpose    = "snet-private-endpoints"
      max_length = 80
    }
  }

  naming_definitions = merge(local.default_naming_definitions, var.naming_overrides)
}

module "naming" {
  source               = "../../terraform-modules/naming"
  org_code             = var.org_code
  project_code         = var.project_code
  environment          = var.environment
  location             = var.location
  resource_definitions = local.naming_definitions
}

locals {
  tags = merge({
    environment = module.naming.tokens.environment,
    location    = module.naming.tokens.location,
    workload    = module.naming.tokens.project,
  }, var.tags)

  resource_names = module.naming.names
}

resource "azurerm_resource_group" "network" {
  name     = local.resource_names.rg_network
  location = var.location
  tags     = local.tags
}

module "common_vnet" {
  source              = "../../terraform-modules/vnet"
  name                = local.resource_names.vnet_common
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.vnet_address_space
  tags                = local.tags
  subnets = {
    (local.resource_names.snet_private_endpoints) = {
      address_prefixes                              = [var.private_endpoint_subnet_prefix]
      private_endpoint_network_policies             = "Disabled"
      private_link_service_network_policies_enabled = false
    }
  }
}
