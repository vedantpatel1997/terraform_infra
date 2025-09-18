variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "spoke_client_id" {
  type = string
}

variable "spoke_client_secret" {
  type      = string
  sensitive = true
}

variable "spoke_client_object_id" {
  type = string
}

variable "hub_subscription_id" {
  type = string
}

variable "hub_tenant_id" {
  type = string
}

variable "hub_client_id" {
  type = string
}

variable "hub_client_secret" {
  type      = string
  sensitive = true
}

variable "hub_resource_group_name" {
  type = string
}

variable "hub_vnet_name" {
  type = string
}

variable "spoke_to_hub_peering_name" {
  type    = string
  default = "spoke-to-hub"
}

variable "hub_to_spoke_peering_name" {
  type    = string
  default = "hub-to-spoke"
}

variable "hub_private_dns_resolver_name" {
  type    = string
  default = null
}

variable "hub_private_dns_resolver_inbound_endpoint_name" {
  type    = string
  default = null
}

variable "hub_private_dns_resolver_static_ips" {
  type    = list(string)
  default = []
}

variable "hub_private_dns_resolver_fallback_ip" {
  type    = string
  default = "11.0.1.68"
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

variable "appservice_plan_purpose" {
  description = "Descriptor for the App Service plan workload or runtime (for example, linux)."
  type        = string
  default     = "linux"
}

variable "frontend_image_repository" {
  type = string
}

variable "frontend_image_tag" {
  type = string
}

variable "frontend_container_port" {
  type = number
}

variable "backend_image_repository" {
  type = string
}

variable "backend_image_tag" {
  type = string
}

variable "backend_container_port" {
  type = number
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
