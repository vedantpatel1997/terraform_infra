subscription_id = "6a3bb170-5159-4bff-860b-aa74fb762697"
tenant_id       = "be945e7a-2e17-4b44-926f-512e85873eec"

location = "westus3"
tags = {
  env   = "dev"
  owner = "vedant"
}

rg_net = "rg-vkp-dev-network-westus3"
rg_acr = "rg-vkp-dev-acr-westus3"
rg_dns = "rg-vkp-dev-dns-westus3"
rg_app = "rg-vkp-dev-apps-westus3"

vnet_name        = "vnet-vkp-dev-westus3"
vnet_cidr        = "10.51.0.0/16"
snet_appsvc_cidr = "10.51.1.0/24"
snet_pe_cidr     = "10.51.2.0/24"

acr_name = "acrvkpdevwestus3"

plan_name = "asp-vkp-dev-linux-westus3"
plan_sku  = "P1v3"

app_name         = "app-vkp-dev-orders-westus3"
image_repository = "org/orders"
image_tag        = "bootstrap"
container_port   = 8080
