variable "name" {
  type        = string
  description = "Name of the Key Vault."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group hosting the Key Vault."
}

variable "location" {
  type        = string
  description = "Azure region for the Key Vault."
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID for the Key Vault."
}

variable "sku_name" {
  type        = string
  description = "SKU name for the Key Vault."
  default     = "standard"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the Key Vault."
  default     = {}
}
