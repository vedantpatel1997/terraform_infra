resource "azurerm_mssql_server" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.server_version
  administrator_login           = var.administrator_login
  administrator_login_password  = var.administrator_login_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = var.tags
}

resource "azurerm_mssql_database" "this" {
  for_each           = var.databases
  name               = each.key
  server_id          = azurerm_mssql_server.this.id
  sku_name           = each.value.service_objective
  max_size_gb        = each.value.max_size_gb
  zone_redundant     = each.value.zone_redundant
  geo_backup_enabled = false
  tags               = var.tags
}
