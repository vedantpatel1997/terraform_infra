resource "azurerm_servicebus_namespace" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  tags                = var.tags
}

resource "azurerm_servicebus_queue" "this" {
  for_each = var.queues

  name               = each.key
  namespace_id       = azurerm_servicebus_namespace.this.id
  lock_duration      = each.value.lock_duration
  max_delivery_count = each.value.max_delivery_count
}
