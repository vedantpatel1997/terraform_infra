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
  description = "ID of the virtual network that hosts the private endpoints consuming the zones."
}

variable "vnet_name" {
  type        = string
  description = "Name used when constructing private DNS link resource names."
}

variable "linked_vnet_ids" {
  type        = list(string)
  description = "List of virtual network resource IDs that should be linked to each private DNS zone."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to DNS resources."
  default     = {}
}
