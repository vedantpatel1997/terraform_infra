output "resource_group_name" {
  description = "Resource group hosting the dev spoke network."
  value       = azurerm_resource_group.network.name
}

output "vnet_id" {
  description = "Identifier of the dev virtual network."
  value       = module.spoke_vnet.id
}

output "subnet_ids" {
  description = "Map of subnet names to subnet IDs for the dev VNet."
  value       = module.spoke_vnet.subnet_ids
}
