output "plan_id" {
  description = "Resource ID of the App Service plan."
  value       = azurerm_service_plan.this.id
}

output "resource_group_name" {
  description = "Name of the resource group hosting the App Service plan."
  value       = azurerm_resource_group.this.name
}
