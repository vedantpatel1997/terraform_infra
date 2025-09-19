variable "name" {
  type        = string
  description = "Name of the private endpoint."
}

variable "location" {
  type        = string
  description = "Azure region of the private endpoint."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group that will host the private endpoint."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the private endpoint will be placed."
}

variable "private_service_connection" {
  description = "Configuration for the private service connection."
  type = object({
    name                           = string
    is_manual_connection           = optional(bool, false)
    private_connection_resource_id = string
    subresource_names              = optional(list(string), [])
  })
}

variable "private_dns_zone_ids" {
  description = "Optional set of Private DNS zone IDs to associate with the endpoint."
  type        = list(string)
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the private endpoint."
  default     = {}
}
