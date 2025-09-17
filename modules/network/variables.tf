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

variable "env" {
  type        = string
  description = "Environment code used for network-scoped resources."
}

variable "appsvc_subnet" {
  type = object({
    name   = string
    prefix = string
  })
  description = "Configuration for the App Service integration subnet."
}

variable "private_endpoint_subnet" {
  type = object({
    name   = string
    prefix = string
  })
  description = "Configuration for the private endpoint subnet."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to networking resources."
  default     = {}
}
