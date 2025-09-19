output "id" {
  description = "Identifier of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet names to subnet IDs."
  value = {
    for name, subnet in azurerm_subnet.this :
    name => subnet.id
  }
}
