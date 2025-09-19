locals {
  private_service_connection = merge(var.private_service_connection, {
    is_manual_connection = try(var.private_service_connection.is_manual_connection, false)
    subresource_names    = try(var.private_service_connection.subresource_names, [])
  })
}

resource "azurerm_private_endpoint" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = local.private_service_connection.name
    private_connection_resource_id = local.private_service_connection.private_connection_resource_id
    is_manual_connection           = local.private_service_connection.is_manual_connection
    subresource_names              = local.private_service_connection.subresource_names
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [var.private_dns_zone_ids] : []

    content {
      name                 = format("%s-zone-group", var.name)
      private_dns_zone_ids = private_dns_zone_group.value
    }
  }
}
