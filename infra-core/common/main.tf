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
