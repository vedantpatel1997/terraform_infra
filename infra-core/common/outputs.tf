output "resource_group_name" {
  description = "Resource group hosting the common network."
  value       = azurerm_resource_group.network.name
}

output "vnet_id" {
  description = "Identifier of the common virtual network."
  value       = module.common_vnet.id
}

output "subnet_ids" {
  description = "Map of subnet names to subnet IDs for the common VNet."
  value       = module.common_vnet.subnet_ids
}

output "private_dns_zone_ids" {
  description = "Map of private DNS zone keys to zone IDs created for the common network."
  value       = module.private_dns.zone_ids
}

output "private_endpoint_ids" {
  description = "Map of private endpoint keys to endpoint IDs created in the common VNet."
  value = {
    for key, endpoint in module.private_endpoints :
    key => endpoint.id
  }
}
