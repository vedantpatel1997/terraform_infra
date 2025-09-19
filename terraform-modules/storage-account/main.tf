resource "azurerm_storage_account" "this" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  account_kind               = var.account_kind
  account_tier               = var.account_tier
  account_replication_type   = var.account_replication_type
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"
  tags                       = var.tags
}
