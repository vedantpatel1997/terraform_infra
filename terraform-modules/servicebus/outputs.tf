output "namespace_id" {
  description = "Resource ID of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.id
}

output "namespace_name" {
  description = "Name of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.name
}

output "queue_ids" {
  description = "Map of queue names to queue IDs."
  value = {
    for name, queue in azurerm_servicebus_queue.this :
    name => queue.id
  }
}
