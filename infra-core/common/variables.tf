variable "org_code" {
  type        = string
  description = "Organisation code used for resource naming."
}

variable "environment" {
  type        = string
  description = "Environment identifier (for example, common)."
}

variable "location" {
  type        = string
  description = "Azure region for the common network."
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space allocated to the common virtual network."
}

variable "private_endpoint_subnet_prefix" {
  type        = string
  description = "CIDR prefix for private endpoints hosted in the common VNet."
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID hosting the shared core resources."
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID hosting the shared core subscription."
}

variable "client_id" {
  type        = string
  description = "Service principal client ID used for Azure authentication."
}

variable "client_secret" {
  type        = string
  description = "Service principal client secret used for Azure authentication."
  sensitive   = true
}

variable "hub_subscription_id" {
  type        = string
  description = "Subscription ID hosting the hub virtual network."
}

variable "hub_tenant_id" {
  type        = string
  description = "Tenant ID hosting the hub subscription."
}

variable "hub_resource_group_name" {
  type        = string
  description = "Resource group containing the hub virtual network."
}

variable "hub_vnet_name" {
  type        = string
  description = "Name of the hub virtual network."
}

variable "hub_private_dns_resolver_name" {
  type        = string
  description = "Name of the Private DNS resolver hosting inbound endpoints for the hub."
}

variable "hub_private_dns_inbound_endpoint_name" {
  type        = string
  description = "Name of the Private DNS resolver inbound endpoint to use for DNS servers."
}

variable "private_dns_zones" {
  description = "Map of Private DNS zone definitions to provision and link to the hub/common VNets."
  type = map(object({
    name                       = string
    link_to_common_vnet        = optional(bool, true)
    link_to_hub_vnet           = optional(bool, true)
    additional_linked_vnet_ids = optional(list(string), [])
    registration_enabled       = optional(bool, false)
    tags                       = optional(map(string), {})
  }))
  default = {}
}

variable "additional_private_dns_link_vnet_ids" {
  type        = list(string)
  description = "Additional virtual network IDs to link to each Private DNS zone."
  default     = []
}

variable "private_endpoints" {
  description = "Map of private endpoint definitions to create within the common VNet."
  type = map(object({
    target_resource_id = string
    subresource_names  = optional(list(string), [])
    manual_connection  = optional(bool, false)
    zone_keys          = optional(list(string), [])
    tags               = optional(map(string), {})
  }))
  default = {}
}

variable "naming_overrides" {
  type        = map(any)
  description = "Optional overrides for resource naming definitions."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to core networking resources."
  default     = {}
}
