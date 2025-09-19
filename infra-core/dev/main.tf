locals {
  default_naming_definitions = {
    rg_network = {
      purpose       = "rg-network"
      resource_type = "resource_group"
    }
    vnet_spoke = {
      purpose    = "vnet"
      max_length = 64
    }
    snet_app = {
      purpose    = "snet-apps"
      max_length = 80
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
  peering_names = {
    to_hub   = format("%s-to-hub", module.naming.tokens.environment)
    from_hub = format("hub-to-%s", module.naming.tokens.environment)
  }
}

resource "azurerm_resource_group" "network" {
  name     = local.resource_names.rg_network
  location = var.location
  tags     = local.tags
}

module "spoke_vnet" {
  source              = "../../terraform-modules/vnet"
  name                = local.resource_names.vnet_spoke
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.vnet_address_space
  dns_servers = [
    for config in data.azurerm_private_dns_resolver_inbound_endpoint.hub.ip_configurations :
    config.private_ip_address
  ]
  tags = local.tags
  subnets = {
    (local.resource_names.snet_app) = {
      address_prefixes = [var.app_subnet_prefix]
      service_endpoints = [
        "Microsoft.Storage",
      ]
      delegation = {
        name                       = "appsvc-delegation"
        service_delegation_name    = "Microsoft.Web/serverFarms"
        service_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    (local.resource_names.snet_private_endpoints) = {
      address_prefixes                              = [var.private_endpoint_subnet_prefix]
      private_endpoint_network_policies             = "Disabled"
      private_link_service_network_policies_enabled = false
    }
  }
}

data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_resource_group_name

  provider = azurerm.hub
}

data "azurerm_private_dns_resolver" "hub" {
  name                = var.hub_private_dns_resolver_name
  resource_group_name = var.hub_resource_group_name

  provider = azurerm.hub
}

data "azurerm_private_dns_resolver_inbound_endpoint" "hub" {
  name                    = var.hub_private_dns_inbound_endpoint_name
  private_dns_resolver_id = data.azurerm_private_dns_resolver.hub.id

  provider = azurerm.hub
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = local.peering_names.to_hub
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = module.spoke_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true

  depends_on = [module.spoke_vnet]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = local.peering_names.from_hub
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = module.spoke_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true

  provider = azurerm.hub
}
