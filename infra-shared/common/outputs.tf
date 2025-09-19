output "shared_resource_group_name" {
  description = "Resource group hosting shared services."
  value       = azurerm_resource_group.shared.name
}

output "dns_resource_group_name" {
  description = "Resource group hosting private DNS zones."
  value       = azurerm_resource_group.dns.name
}

output "acr_login_server" {
  description = "Login server for the shared Azure Container Registry."
  value       = module.acr.login_server
}

output "acr_id" {
  description = "Resource ID of the shared Azure Container Registry."
  value       = module.acr.id
}

output "servicebus_namespace_name" {
  description = "Name of the shared Service Bus namespace."
  value       = module.servicebus.namespace_name
}

output "servicebus_namespace_id" {
  description = "Resource ID of the shared Service Bus namespace."
  value       = module.servicebus.namespace_id
}

output "storage_account_name" {
  description = "Name of the shared storage account."
  value       = module.storage.name
}

output "storage_account_id" {
  description = "Resource ID of the shared storage account."
  value       = module.storage.id
}

output "key_vault_uri" {
  description = "URI for the shared Key Vault."
  value       = module.keyvault.vault_uri
}

output "key_vault_id" {
  description = "Resource ID of the shared Key Vault."
  value       = module.keyvault.id
}

output "sql_server_fqdn" {
  description = "Fully-qualified domain name for the shared SQL server."
  value       = module.sql.fully_qualified_domain_name
}

output "sql_server_id" {
  description = "Resource ID of the shared SQL server."
  value       = module.sql.server_id
}

output "sql_database_ids" {
  description = "Map of shared SQL database names to IDs."
  value       = module.sql.database_ids
}

output "private_dns_zone_ids" {
  description = "Map of private DNS zones created for shared services."
  value       = module.private_dns.zone_ids
}

output "uami_dev" {
  description = "Identifiers for the dev environment managed identity."
  value = {
    id           = module.uami_dev.id
    client_id    = module.uami_dev.client_id
    principal_id = module.uami_dev.principal_id
  }
}

output "uami_prod" {
  description = "Identifiers for the prod environment managed identity."
  value = {
    id           = module.uami_prod.id
    client_id    = module.uami_prod.client_id
    principal_id = module.uami_prod.principal_id
  }
}
