variable "org_code" {
  description = "Short code representing the organization (for example, vkp)."
  type        = string
}

variable "project_code" {
  description = "Short code representing the workload or project."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (for example, dev, qa, prod)."
  type        = string
}

variable "location" {
  description = "Azure region where the resources will be deployed (for example, westus3)."
  type        = string
}

variable "resource_definitions" {
  description = <<EOT
Map describing the purposes and resource-type specific constraints for generated names.
Each key represents a logical resource and the value contains:
  - purpose        : descriptive token inserted between project and environment tokens.
  - resource_type  : optional classification that applies resource-specific rules (for example, "acr", "storage").
  - max_length     : optional maximum length for the generated name. Defaults to a sensible limit per resource type.
EOT
  type = map(object({
    purpose       = string
    resource_type = optional(string)
    max_length    = optional(number)
  }))
  default = {}
}
