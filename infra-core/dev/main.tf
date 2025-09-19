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

  raw_tokens = {
    org         = var.org_code
    component   = "infra core"
    environment = var.environment
    location    = var.location
  }

  sanitized_tokens = {
    for key, value in local.raw_tokens :
    key => trim(
      regexreplace(
        regexreplace(
          replace(lower(trimspace(value)), "_", "-"),
          "[^a-z0-9-]",
          "-",
        ),
        "-{2,}",
        "-",
      ),
      "-",
    )
  }

  default_max_length = {
    generic        = 80
    resource_group = 90
    storage        = 24
    acr            = 50
    key_vault      = 24
  }

  sanitized_resource_definitions = {
    for key, definition in local.naming_definitions :
    key => {
      purpose = trim(
        regexreplace(
          regexreplace(
            replace(lower(trimspace(definition.purpose)), "_", "-"),
            "[^a-z0-9-]",
            "-",
          ),
          "-{2,}",
          "-",
        ),
        "-",
      )
      resource_type = coalesce(lookup(definition, "resource_type", null), "generic")
      max_length = coalesce(
        lookup(definition, "max_length", null),
        lookup(local.default_max_length, coalesce(lookup(definition, "resource_type", null), "generic"), 80),
      )
    }
  }

  resource_tokens = {
    for key, definition in local.sanitized_resource_definitions :
    key => compact([
      local.sanitized_tokens.org,
      local.sanitized_tokens.component,
      definition.purpose,
      local.sanitized_tokens.environment,
      local.sanitized_tokens.location,
    ])
  }

  joiner_overrides = {
    storage = ""
    acr     = ""
  }

  resource_joined_names = {
    for key, definition in local.sanitized_resource_definitions :
    key => join(lookup(local.joiner_overrides, definition.resource_type, "-"), local.resource_tokens[key])
  }

  resource_names = {
    for key, definition in local.sanitized_resource_definitions :
    key => substr(
      local.resource_joined_names[key],
      0,
      min(length(local.resource_joined_names[key]), definition.max_length),
    )
  }

  base_tags = {
    environment = local.sanitized_tokens.environment
    location    = local.sanitized_tokens.location
    workload    = local.sanitized_tokens.component
  }

  tags = merge(local.base_tags, var.tags)

  peering_names = {
    to_hub   = format("%s-to-hub", local.sanitized_tokens.environment)
    from_hub = format("hub-to-%s", local.sanitized_tokens.environment)
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
