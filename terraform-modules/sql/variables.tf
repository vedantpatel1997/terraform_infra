variable "name" {
  type        = string
  description = "Name of the SQL server."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group that will host the SQL server."
}

variable "location" {
  type        = string
  description = "Azure region for the SQL server."
}

variable "administrator_login" {
  type        = string
  description = "Administrator login for the SQL server."
}

variable "administrator_login_password" {
  type        = string
  description = "Administrator password for the SQL server."
  sensitive   = true
}

variable "server_version" {
  type        = string
  description = "Version of Azure SQL."
  default     = "12.0"
}

variable "databases" {
  description = "Map of databases to create with edition and service objective."
  type = map(object({
    edition           = optional(string, "GeneralPurpose")
    max_size_gb       = optional(number, 32)
    service_objective = optional(string, "GP_Gen5_2")
    zone_redundant    = optional(bool, false)
  }))
  default = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to SQL resources."
  default     = {}
}
