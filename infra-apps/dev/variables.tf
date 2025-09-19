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
  description = "Environment identifier (for example, dev)."
}

variable "location" {
  type        = string
  description = "Azure region for application workloads."
}

variable "plan_sku" {
  type        = string
  description = "App Service plan SKU (for example, P1v3)."
}

variable "acr_id" {
  type        = string
  description = "Resource ID of the shared Azure Container Registry."
}

variable "acr_login_server" {
  type        = string
  description = "Login server of the shared Azure Container Registry."
}

variable "appsvc_subnet_id" {
  type        = string
  description = "Subnet ID used for App Service VNet integration."
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID used for App Service private endpoints."
}

variable "web_private_dns_zone_id" {
  type        = string
  description = "Private DNS zone ID for Azure Web Apps."
}

variable "uami_id" {
  type        = string
  description = "Resource ID of the user-assigned managed identity for the environment."
}

variable "uami_client_id" {
  type        = string
  description = "Client ID of the user-assigned managed identity."
}

variable "uami_principal_id" {
  type        = string
  description = "Principal ID of the user-assigned managed identity."
}

variable "frontend_image_repository" {
  type        = string
  description = "Repository path for the frontend container image."
}

variable "frontend_image_tag" {
  type        = string
  description = "Tag for the frontend container image."
}

variable "frontend_container_port" {
  type        = number
  description = "Container port exposed by the frontend service."
}

variable "frontend_app_settings" {
  type        = map(string)
  description = "Additional app settings for the frontend web app."
  default     = {}
}

variable "backend_image_repository" {
  type        = string
  description = "Repository path for the backend container image."
}

variable "backend_image_tag" {
  type        = string
  description = "Tag for the backend container image."
}

variable "backend_container_port" {
  type        = number
  description = "Container port exposed by the backend service."
}

variable "backend_app_settings" {
  type        = map(string)
  description = "Additional app settings for the backend web app."
  default     = {}
}

variable "naming_overrides" {
  type        = map(any)
  description = "Optional overrides for resource naming definitions."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to application resources."
  default     = {}
}
