variable "rg_name" {
  type        = string
  description = "Name of the resource group for DNS resources."
}

variable "location" {
  type        = string
  description = "Azure region for tagging consistency."
}

variable "vnet_id" {
  type        = string
  description = "ID of the virtual network to link with the private DNS zones."
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network for naming DNS links."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to DNS resources."
  default     = {}
}
