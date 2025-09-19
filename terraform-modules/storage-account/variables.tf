variable "name" {
  type        = string
  description = "Name of the storage account."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for the storage account."
}

variable "location" {
  type        = string
  description = "Azure region for the storage account."
}

variable "account_kind" {
  type        = string
  description = "Storage account kind."
  default     = "StorageV2"
}

variable "account_tier" {
  type        = string
  description = "Storage account tier."
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "Replication type for the storage account."
  default     = "LRS"
}

variable "tags" {
  type        = map(string)
  description = "Tags to associate with the storage account."
  default     = {}
}
