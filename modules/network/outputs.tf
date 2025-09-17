output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "appsvc_integration_snet_id" {
  description = "Resource ID of the App Service integration subnet."
  value       = azurerm_subnet.app_service_integration.id
}

output "pe_snet_id" {
  description = "Resource ID of the private endpoint subnet."
  value       = azurerm_subnet.private_endpoint.id
}
