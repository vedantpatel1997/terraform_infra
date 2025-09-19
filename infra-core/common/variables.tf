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
