locals {
  tags = var.tags

  naming_tokens = {
    org     = var.org_code
    project = var.project_code
    env     = var.environment
    purpose = var.identity_purpose
  }

  normalized_tokens = {
    for key, value in local.naming_tokens :
    key => replace(
      replace(
        replace(lower(trimspace(value)), "_", "-"),
        " ",
        "-",
      ),
      "--",
      "-",
    )
  }

  user_assigned_identity_name = coalesce(
    var.user_assigned_identity_name,
    format(
      "uai-%s-%s-%s-%s",
      local.normalized_tokens.org,
      local.normalized_tokens.project,
      local.normalized_tokens.env,
      local.normalized_tokens.purpose,
    ),
  )
}

module "network" {
  source             = "../../modules/network"
  env                = var.environment
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

resource "azurerm_user_assigned_identity" "webapp" {
  name                = local.user_assigned_identity_name
  location            = var.location
  resource_group_name = var.rg_app
  tags                = local.tags
}

module "webapp" {
  source                              = "../../modules/appservice/webapp"
  rg_name                             = var.rg_app
  location                            = var.location
  plan_id                             = module.appservice_plan.plan_id
  acr_id                              = module.acr.id
  acr_login_server                    = module.acr.login_server
  app_name                            = var.app_name
  image_repository                    = var.image_repository
  image_tag                           = var.image_tag
  container_port                      = var.container_port
  appsvc_integration_subnet_id        = module.network.appsvc_integration_snet_id
  pe_subnet_id                        = module.network.pe_snet_id
  web_zone_id                         = module.dns.web_zone_id
  app_settings                        = {}
  user_assigned_identity_id           = azurerm_user_assigned_identity.webapp.id
  user_assigned_identity_client_id    = azurerm_user_assigned_identity.webapp.client_id
  user_assigned_identity_principal_id = azurerm_user_assigned_identity.webapp.principal_id
  tags                                = local.tags
}

output "acr_login_server" { value = module.acr.login_server }
output "webapp_name" { value = module.webapp.app_name }
