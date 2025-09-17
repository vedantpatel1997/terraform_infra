resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_registry" "this" {
  name                = var.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Premium"
  admin_enabled       = false
  tags                = var.tags

  network_rule_bypass_option    = "AzureServices"
  public_network_access_enabled = false
  zone_redundancy_enabled       = true
}

resource "azurerm_private_endpoint" "this" {
  name                = "${var.name}-pep"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.pe_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name}-connection"
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-dns-zg"
    private_dns_zone_ids = [var.acr_zone_id]
  }
}
