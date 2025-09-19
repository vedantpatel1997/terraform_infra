locals {
  subnets = {
    for name, config in var.subnets :
    name => merge(config, {
      service_endpoints                             = try(config.service_endpoints, [])
      private_endpoint_network_policies             = try(config.private_endpoint_network_policies, null)
      private_link_service_network_policies_enabled = try(config.private_link_service_network_policies_enabled, null)
      delegation                                    = try(config.delegation, null)
    })
  }
}

resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = local.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = coalesce(each.value.service_endpoints, [])

  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = each.value.delegation == null ? [] : [each.value.delegation]

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation_name
        actions = delegation.value.service_delegation_actions
      }
    }
  }
}
