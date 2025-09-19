resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_service_plan" "this" {
  name                = var.plan_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = var.plan_sku
  tags                = var.tags

  per_site_scaling_enabled = false
  zone_balancing_enabled   = false
}
