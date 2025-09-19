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
