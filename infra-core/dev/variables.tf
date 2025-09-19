variable "org_code" {
  type        = string
  description = "Organisation code used for resource naming."
}

variable "project_code" {
  type        = string
  description = "Project code used for resource naming."
}

variable "environment" {
  type        = string
  description = "Environment identifier (for example, dev)."
}

variable "location" {
  type        = string
  description = "Azure region for the spoke network."
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space allocated to the spoke virtual network."
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

variable "spoke_tenant_id" {
  type        = string
  description = "Tenant ID hosting the spoke subscription."
}

variable "spoke_subscription_id" {
  type        = string
  description = "Subscription ID hosting the dev spoke resources."
}

variable "app_subnet_prefix" {
  type        = string
  description = "CIDR prefix for application workloads (App Service / Container Apps)."
}

variable "private_endpoint_subnet_prefix" {
  type        = string
  description = "CIDR prefix for private endpoints in the spoke."
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
  description = "Name of the Private DNS resolver inbound endpoint to use for spoke DNS servers."
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
