variable "name" {
  type        = string
  description = "Name of the Service Bus namespace."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group hosting the namespace."
}

variable "location" {
  type        = string
  description = "Azure region for the namespace."
}

variable "sku" {
  type        = string
  description = "SKU for the Service Bus namespace."
  default     = "Standard"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to Service Bus resources."
  default     = {}
}

variable "queues" {
  description = "Optional map of queue definitions to create inside the namespace."
  type = map(object({
    max_delivery_count = optional(number, 10)
    lock_duration      = optional(string, "PT30S")
  }))
  default = {}
}
