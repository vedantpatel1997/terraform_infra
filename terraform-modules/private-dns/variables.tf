variable "resource_group_name" {
  type        = string
  description = "Resource group that will host the Private DNS zones."
}

variable "zones" {
  description = "Map of Private DNS zone definitions keyed by a short name."
  type = map(object({
    name                 = string
    linked_vnet_ids      = list(string)
    registration_enabled = optional(bool, false)
    tags                 = optional(map(string), {})
  }))
}
