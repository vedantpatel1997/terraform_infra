subscription_id     = "6a3bb170-5159-4bff-860b-aa74fb762697"
tenant_id           = "xxxx"
client_id           = "xxxxx"
client_secret       = "xxxx"
hub_subscription_id = "f1c89731-86b0-4cd4-bd2d-f2347c1d62d2"
hub_tenant_id       = "f913f484-b59e-49a4-95ce-feddd38dc57a"
hub_resource_group_name = "neworkhubrg"
hub_vnet_name           = "Hub-Vnet"
hub_private_dns_resolver_name                  = "<hub-private-dns-resolver-name>"
hub_private_dns_resolver_inbound_endpoint_name = "<hub-private-dns-inbound-endpoint-name>"
hub_private_dns_resolver_static_ips            = []

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
