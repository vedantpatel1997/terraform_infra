variable "name" {
  type        = string
  description = "Name of the user-assigned managed identity."
}

variable "location" {
  type        = string
  description = "Azure region for the identity."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group that will contain the identity."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the identity resource."
  default     = {}
}

variable "role_assignments" {
  description = "Optional list of role assignments to create for the identity."
  type = list(object({
    scope                = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
  }))
  default = []
}
