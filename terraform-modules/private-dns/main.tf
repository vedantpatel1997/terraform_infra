locals {
  zones = {
    for key, zone in var.zones :
    key => merge(zone, {
      registration_enabled = try(zone.registration_enabled, false)
      tags                 = try(zone.tags, {})
    })
  }

  zone_links = flatten([
    for zone_key, zone in local.zones : [
      for idx, vnet_id in zone.linked_vnet_ids : {
        key    = format("%s-%02d", zone_key, idx)
        zone   = zone_key
        vnet   = vnet_id
        index  = idx
        tags   = zone.tags
        enable = zone.registration_enabled
      }
    ]
  ])
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = local.zones
  name                = each.value.name
  resource_group_name = var.resource_group_name
  tags                = each.value.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = { for link in local.zone_links : link.key => link }

  name                  = format("%s-link-%02d", azurerm_private_dns_zone.this[each.value.zone].name, each.value.index + 1)
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.zone].name
  virtual_network_id    = each.value.vnet
  registration_enabled  = each.value.enable
  tags                  = each.value.tags
}
