resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

locals {
  zones = {
    acr = {
      name = "privatelink.azurecr.io"
    }
    web = {
      name = "privatelink.azurewebsites.net"
    }
  }

  link_target_vnet_ids = coalescelist(var.linked_vnet_ids, [var.vnet_id])

  zone_vnet_links = {
    for pair in setproduct(keys(local.zones), local.link_target_vnet_ids) :
    format("%s-%d", pair[0], index(local.link_target_vnet_ids, pair[1])) => {
      zone_key = pair[0]
      vnet_id  = pair[1]
      index    = index(local.link_target_vnet_ids, pair[1])
    }
  }
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = local.zones
  name                = each.value.name
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = local.zone_vnet_links

  name                  = format("%s-%s-link-%02d", var.vnet_name, each.value.zone_key, each.value.index + 1)
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.zone_key].name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}
