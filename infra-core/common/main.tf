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

  raw_tokens = {
    org         = var.org_code
    component   = "infra core"
    environment = var.environment
    location    = var.location
  }

  sanitized_tokens = {
    for key, value in local.raw_tokens :
    key => join(
      "-",
      regexall(
        "[a-z0-9]+",
        replace(lower(trimspace(value)), "_", " "),
      ),
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
      purpose = join(
        "-",
        regexall(
          "[a-z0-9]+",
          replace(lower(trimspace(definition.purpose)), "_", " "),
        ),
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

module "common_vnet" {
  source              = "../../terraform-modules/vnet"
  name                = local.resource_names.vnet_common
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.vnet_address_space
  dns_servers = [
    for config in data.azurerm_private_dns_resolver_inbound_endpoint.hub.ip_configurations :
    config.private_ip_address
  ]
  tags = local.tags
  subnets = {
    (local.resource_names.snet_private_endpoints) = {
      address_prefixes                              = [var.private_endpoint_subnet_prefix]
      private_endpoint_network_policies             = "Disabled"
      private_link_service_network_policies_enabled = false
    }
  }
}

locals {
  private_dns_zone_definitions = {
    for key, zone in var.private_dns_zones :
    key => {
      name = zone.name
      linked_vnet_ids = distinct(concat(
        try(zone.link_to_common_vnet, true) ? [module.common_vnet.id] : [],
        try(zone.link_to_hub_vnet, true) ? [data.azurerm_virtual_network.hub.id] : [],
        var.additional_private_dns_link_vnet_ids,
        try(zone.additional_linked_vnet_ids, []),
      ))
      registration_enabled = try(zone.registration_enabled, false)
      tags                 = merge(local.tags, try(zone.tags, {}))
    }
  }

  private_endpoint_tokens = {
    for key in keys(var.private_endpoints) :
    key => trim(
      regexreplace(
        regexreplace(lower(trimspace(key)), "[^a-z0-9-]", "-"),
        "-{2,}",
        "-",
      ),
      "-",
    )
  }
}

module "private_dns" {
  source              = "../../terraform-modules/private-dns"
  resource_group_name = azurerm_resource_group.network.name
  zones               = local.private_dns_zone_definitions
}

module "private_endpoints" {
  source   = "../../terraform-modules/private-endpoint"
  for_each = var.private_endpoints

  name                = format("%s-%s-pe", local.resource_names.vnet_common, local.private_endpoint_tokens[each.key])
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  subnet_id           = module.common_vnet.subnet_ids[local.resource_names.snet_private_endpoints]
  tags                = merge(local.tags, try(each.value.tags, {}))

  private_service_connection = {
    name                           = format("%s-%s-connection", local.resource_names.vnet_common, local.private_endpoint_tokens[each.key])
    private_connection_resource_id = each.value.target_resource_id
    is_manual_connection           = try(each.value.manual_connection, false)
    subresource_names              = try(each.value.subresource_names, [])
  }

  private_dns_zone_ids = [
    for zone_key in try(each.value.zone_keys, []) :
    module.private_dns.zone_ids[zone_key]
  ]
}

resource "azurerm_virtual_network_peering" "common_to_hub" {
  name                      = local.peering_names.to_hub
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = module.common_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true

  depends_on = [module.common_vnet]
}

resource "azurerm_virtual_network_peering" "hub_to_common" {
  name                      = local.peering_names.from_hub
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = module.common_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true

  provider = azurerm.hub
}
