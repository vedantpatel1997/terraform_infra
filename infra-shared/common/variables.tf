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
  description = "Environment identifier for shared services (for example, shared)."
}

variable "location" {
  type        = string
  description = "Azure region where shared services are deployed."
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID required for Key Vault provisioning."
}

variable "common_vnet_id" {
  type        = string
  description = "Resource ID of the common virtual network hosting private endpoints."
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID dedicated to private endpoints within the common VNet."
}

variable "additional_dns_link_vnet_ids" {
  type        = list(string)
  description = "Additional VNet IDs to link to private DNS zones."
  default     = []
}

variable "sql_administrator_login" {
  type        = string
  description = "Administrator login for the Azure SQL server."
}

variable "sql_administrator_password" {
  type        = string
  description = "Administrator password for the Azure SQL server."
  sensitive   = true
}

variable "sql_databases" {
  description = "Map of database names to configuration objects."
  type = map(object({
    edition           = optional(string, "GeneralPurpose")
    max_size_gb       = optional(number, 32)
    service_objective = optional(string, "GP_Gen5_2")
    zone_redundant    = optional(bool, false)
  }))
  default = {
    dev  = {}
    prod = {}
  }
}

variable "servicebus_queues" {
  description = "Map of Service Bus queue names to configuration objects."
  type = map(object({
    max_delivery_count = optional(number, 10)
    lock_duration      = optional(string, "PT30S")
  }))
  default = {
    dev-processing  = {}
    prod-processing = {}
  }
}

variable "naming_overrides" {
  type        = map(any)
  description = "Optional overrides for resource naming definitions."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to shared resources."
  default     = {}
}
