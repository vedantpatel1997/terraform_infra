variable "name" {
  type        = string
  description = "Name of the virtual network."
}

variable "location" {
  type        = string
  description = "Azure region for the virtual network."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group where the virtual network will be created."
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the virtual network."
}

variable "dns_servers" {
  type        = list(string)
  description = "Custom DNS servers to associate with the VNet."
  default     = []
}

variable "subnets" {
  description = "Map of subnet configurations keyed by subnet name."
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string))
    delegation = optional(object({
      name                       = string
      service_delegation_name    = string
      service_delegation_actions = list(string)
    }))
    private_endpoint_network_policies             = optional(string)
    private_link_service_network_policies_enabled = optional(bool)
  }))
  default = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the virtual network and subnets."
  default     = {}
}
