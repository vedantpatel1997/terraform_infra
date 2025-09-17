subscription_id = "6a3bb170-5159-4bff-860b-aa74fb762697"
tenant_id       = "be945e7a-2e17-4b44-926f-512e85873eec"

location                = "westus3"
org_code                = "vkp"
project_code            = "library"
environment             = "production"
identity_purpose        = "webapp"
appservice_plan_purpose = "linux"
tags = {
  owner = "vedant"
}

vnet_cidr        = "10.51.0.0/16"
snet_appsvc_cidr = "10.51.1.0/24"
snet_pe_cidr     = "10.51.2.0/24"

plan_sku                  = "P0v3"
frontend_image_repository = "org/frontend"
frontend_image_tag        = "bootstrap"
frontend_container_port   = 8080
backend_image_repository  = "org/backend"
backend_image_tag         = "bootstrap"
backend_container_port    = 8080
