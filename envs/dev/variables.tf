variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "location" {
  type = string
}

variable "org_code" {
  description = "Short code that identifies the organization (for example, vkp)."
  type        = string
}

variable "project_code" {
  description = "Short code that identifies the workload or project the resources belong to."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (for example, dev, qa, prod)."
  type        = string
}

variable "identity_purpose" {
  description = "Describes what the user-assigned identity will be attached to (for example, webapp)."
  type        = string
  default     = "webapp"
}

variable "user_assigned_identity_name" {
  description = "Optional override for the user-assigned identity resource name."
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vnet_cidr" {
  type = string
}

variable "snet_appsvc_cidr" {
  type = string
}

variable "snet_pe_cidr" {
  type = string
}

variable "plan_sku" {
  type = string
}

variable "image_repository" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "container_port" {
  type = number
}

variable "app_component" {
  description = "Functional name of the web application component (for example, orders)."
  type        = string
}

variable "appservice_plan_purpose" {
  description = "Descriptor for the App Service plan workload or runtime (for example, linux)."
  type        = string
  default     = "linux"
}

variable "naming_overrides" {
  description = "Optional map to override the default naming purposes or constraints for specific resources."
  type = map(object({
    purpose       = string
    resource_type = optional(string)
    max_length    = optional(number)
  }))
  default = {}
}
