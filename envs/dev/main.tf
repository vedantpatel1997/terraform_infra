locals {
  tags = var.tags
}

module "network" {
  source             = "../../modules/network"
  env                = "dev"
  rg_name            = var.rg_net
  location           = var.location
  vnet_name          = var.vnet_name
  vnet_address_space = [var.vnet_cidr]
  snet_appsvc_prefix = var.snet_appsvc_cidr
  snet_pe_prefix     = var.snet_pe_cidr
  tags               = local.tags
}

module "dns" {
  source    = "../../modules/private-dns"
  rg_name   = var.rg_dns
  location  = var.location
  vnet_id   = module.network.vnet_id
  vnet_name = var.vnet_name
  tags      = local.tags
}

module "acr" {
  source       = "../../modules/acr"
  rg_name      = var.rg_acr
  location     = var.location
  name         = var.acr_name
  pe_subnet_id = module.network.pe_snet_id
  acr_zone_id  = module.dns.acr_zone_id
  tags         = local.tags
}

module "appservice_plan" {
  source    = "../../modules/appservice/plan"
  rg_name   = var.rg_app
  location  = var.location
  plan_name = var.plan_name
  plan_sku  = var.plan_sku
  tags      = local.tags
}

module "webapp" {
  source                       = "../../modules/appservice/webapp"
  rg_name                      = var.rg_app
  location                     = var.location
  plan_id                      = module.appservice_plan.plan_id
  acr_id                       = module.acr.id
  acr_login_server             = module.acr.login_server
  app_name                     = var.app_name
  image_repository             = var.image_repository
  image_tag                    = var.image_tag
  container_port               = var.container_port
  appsvc_integration_subnet_id = module.network.appsvc_integration_snet_id
  pe_subnet_id                 = module.network.pe_snet_id
  web_zone_id                  = module.dns.web_zone_id
  scm_zone_id                  = module.dns.scm_zone_id
  app_settings                 = {}
  tags                         = local.tags
}

output "acr_login_server" { value = module.acr.login_server }
output "webapp_name" { value = module.webapp.app_name }
