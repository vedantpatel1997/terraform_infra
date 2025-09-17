variable "rg_name" {
  type        = string
  description = "Resource group name for the Web App."
}

variable "location" {
  type        = string
  description = "Azure region for the Web App."
}

variable "plan_id" {
  type        = string
  description = "ID of the App Service plan to attach the Web App to."
}

variable "acr_id" {
  type        = string
  description = "ID of the Azure Container Registry used for the container image."
}

variable "acr_login_server" {
  type        = string
  description = "Login server of the Azure Container Registry."
}

variable "app_name" {
  type        = string
  description = "Name of the Web App."
}

variable "image_repository" {
  type        = string
  description = "Repository path inside the Container Registry."
}

variable "image_tag" {
  type        = string
  description = "Tag of the container image."
}

variable "container_port" {
  type        = number
  description = "Port exposed by the container."
}

variable "appsvc_integration_subnet_id" {
  type        = string
  description = "Subnet ID for App Service regional VNet integration."
}

variable "pe_subnet_id" {
  type        = string
  description = "Subnet ID for Web App private endpoints."
}

variable "web_zone_id" {
  type        = string
  description = "Private DNS zone ID used for both Web App and SCM endpoints."
}

variable "app_settings" {
  type        = map(string)
  description = "Additional application settings for the Web App."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}
