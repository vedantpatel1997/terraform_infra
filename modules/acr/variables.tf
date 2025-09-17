variable "rg_name" {
  type        = string
  description = "Name of the resource group for ACR resources."
}

variable "location" {
  type        = string
  description = "Azure region for ACR resources."
}

variable "name" {
  type        = string
  description = "Name of the Azure Container Registry."
}

variable "pe_subnet_id" {
  type        = string
  description = "Resource ID of the subnet used for private endpoints."
}

variable "acr_zone_id" {
  type        = string
  description = "Resource ID of the private DNS zone for Azure Container Registry."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}
