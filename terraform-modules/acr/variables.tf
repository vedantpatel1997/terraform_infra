variable "name" {
  type        = string
  description = "Name of the Azure Container Registry."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group hosting the registry."
}

variable "location" {
  type        = string
  description = "Azure region for the registry."
}

variable "sku" {
  type        = string
  description = "SKU tier for the registry."
  default     = "Premium"
}

variable "admin_enabled" {
  type        = bool
  description = "Whether the admin account is enabled."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the registry."
  default     = {}
}
