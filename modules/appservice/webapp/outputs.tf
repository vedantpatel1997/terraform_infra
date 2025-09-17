output "app_name" {
  description = "Name of the Web App."
  value       = azurerm_linux_web_app.this.name
}

output "principal_id" {
  description = "System assigned identity principal ID for the Web App."
  value       = azurerm_linux_web_app.this.identity[0].principal_id
}
