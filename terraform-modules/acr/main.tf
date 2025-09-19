resource "azurerm_container_registry" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = false
  zone_redundancy_enabled       = false
  network_rule_bypass_option    = "AzureServices"
  tags                          = var.tags
}
