output "zone_ids" {
  description = "Map of zone keys to zone IDs."
  value = {
    for key, zone in azurerm_private_dns_zone.this :
    key => zone.id
  }
}

output "zone_names" {
  description = "Map of zone keys to zone names."
  value = {
    for key, zone in azurerm_private_dns_zone.this :
    key => zone.name
  }
}
