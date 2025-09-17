variable "rg_name" {
  type        = string
  description = "Name of the resource group for the App Service plan."
}

variable "location" {
  type        = string
  description = "Azure region for the App Service plan."
}

variable "plan_name" {
  type        = string
  description = "Name of the App Service plan."
}

variable "plan_sku" {
  type        = string
  description = "SKU for the App Service plan (e.g. P1v3)."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}
