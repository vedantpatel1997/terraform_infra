output "resource_group_name" {
  description = "Resource group hosting application resources."
  value       = module.appservice_plan.resource_group_name
}

output "appservice_plan_id" {
  description = "ID of the App Service plan."
  value       = module.appservice_plan.plan_id
}

output "frontend_webapp_name" {
  description = "Name of the frontend Web App."
  value       = module.frontend_webapp.app_name
}

output "backend_webapp_name" {
  description = "Name of the backend Web App."
  value       = module.backend_webapp.app_name
}
