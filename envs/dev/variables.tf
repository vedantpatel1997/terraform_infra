variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "rg_net" {
  type = string
}

variable "rg_acr" {
  type = string
}

variable "rg_dns" {
  type = string
}

variable "rg_app" {
  type = string
}

variable "vnet_name" {
  type = string
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

variable "acr_name" {
  type = string
}

variable "plan_name" {
  type = string
}

variable "plan_sku" {
  type = string
}

variable "app_name" {
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
