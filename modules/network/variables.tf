variable "rg_name" {
  type        = string
  description = "Name of the resource group for networking resources."
}

variable "location" {
  type        = string
  description = "Azure region for networking resources."
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network."
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network."
}

variable "snet_appsvc_prefix" {
  type        = string
  description = "CIDR prefix for the App Service integration subnet."
}

variable "snet_appsvc_name" {
  type        = string
  description = "Name of the App Service integration subnet."
}

variable "snet_pe_prefix" {
  type        = string
  description = "CIDR prefix for the private endpoint subnet."
}

variable "snet_pe_name" {
  type        = string
  description = "Name of the private endpoint subnet."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to networking resources."
  default     = {}
}
