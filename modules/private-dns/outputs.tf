output "acr_zone_id" {
  description = "Resource ID of the Azure Container Registry private DNS zone."
  value       = azurerm_private_dns_zone.this["acr"].id
}

output "web_zone_id" {
  description = "Resource ID of the Web App private DNS zone."
  value       = azurerm_private_dns_zone.this["web"].id
}

