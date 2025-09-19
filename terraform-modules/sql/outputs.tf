output "server_id" {
  description = "Resource ID of the SQL server."
  value       = azurerm_mssql_server.this.id
}

output "fully_qualified_domain_name" {
  description = "FQDN of the SQL server."
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "database_ids" {
  description = "Map of database names to IDs."
  value = {
    for name, db in azurerm_mssql_database.this :
    name => db.id
  }
}
