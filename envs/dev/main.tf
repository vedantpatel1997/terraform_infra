locals {
  raw_custom_tokens = {
    app_component          = var.app_component
    appservice_plan_option = var.appservice_plan_purpose
    identity_purpose       = var.identity_purpose
  }

  sanitized_custom_tokens = {
    for key, value in local.raw_custom_tokens :
    key => trim(
      replace(
        replace(
          replace(replace(lower(trimspace(value)), "_", "-"), " ", "-"),
          "[^a-z0-9-]",
          "-",
        ),
        "-{2,}",
        "-",
      ),
      "-",
    )
  }

  default_naming_definitions = {
    rg_network = {
      purpose       = "rg-network"
      resource_type = "resource_group"
    }
    rg_dns = {
      purpose       = "rg-dns"
      resource_type = "resource_group"
    }
    rg_acr = {
      purpose       = "rg-acr"
      resource_type = "resource_group"
    }
    rg_app = {
      purpose       = "rg-apps"
      resource_type = "resource_group"
    }
    vnet = {
      purpose    = "vnet"
      max_length = 64
    }
    snet_appsvc = {
      purpose    = "snet-appsvc-integration"
      max_length = 80
    }
    snet_private_endpoint = {
      purpose    = "snet-private-endpoints"
      max_length = 80
    }
    acr = {
      purpose       = "acr"
      resource_type = "acr"
    }
    appservice_plan = {
      purpose    = format("plan-%s", local.sanitized_custom_tokens.appservice_plan_option)
      max_length = 40
    }
    webapp = {
      purpose    = format("app-%s", local.sanitized_custom_tokens.app_component)
      max_length = 60
    }
    identity = {
      purpose    = format("id-%s", local.sanitized_custom_tokens.identity_purpose)
      max_length = 80
    }
  }

  naming_definitions = merge(local.default_naming_definitions, var.naming_overrides)
}

module "naming" {
  source               = "../../modules/naming"
  org_code             = var.org_code
  project_code         = var.project_code
  environment          = var.environment
  location             = var.location
  resource_definitions = local.naming_definitions
}

locals {
  default_tags = {
    environment = module.naming.tokens.environment
    location    = module.naming.tokens.location
    workload    = module.naming.tokens.project
  }

  tags = merge(local.default_tags, var.tags)

  resource_names = module.naming.names

  user_assigned_identity_name = coalesce(
    var.user_assigned_identity_name,
    local.resource_names.identity,
  )
}

module "network" {
  source             = "../../modules/network"
  rg_name            = local.resource_names.rg_network
  location           = var.location
  vnet_name          = local.resource_names.vnet
  vnet_address_space = [var.vnet_cidr]
  snet_appsvc_name   = local.resource_names.snet_appsvc
  snet_appsvc_prefix = var.snet_appsvc_cidr
  snet_pe_name       = local.resource_names.snet_private_endpoint
  snet_pe_prefix     = var.snet_pe_cidr
  tags               = local.tags
}

module "dns" {
  source    = "../../modules/private-dns"
  rg_name   = local.resource_names.rg_dns
  location  = var.location
  vnet_id   = module.network.vnet_id
  vnet_name = local.resource_names.vnet
  tags      = local.tags
}

module "acr" {
  source       = "../../modules/acr"
  rg_name      = local.resource_names.rg_acr
  location     = var.location
  name         = local.resource_names.acr
  pe_subnet_id = module.network.pe_snet_id
  acr_zone_id  = module.dns.acr_zone_id
  tags         = local.tags
}

module "appservice_plan" {
  source    = "../../modules/appservice/plan"
  rg_name   = local.resource_names.rg_app
  location  = var.location
  plan_name = local.resource_names.appservice_plan
  plan_sku  = var.plan_sku
  tags      = local.tags
}

resource "azurerm_user_assigned_identity" "webapp" {
  name                = local.user_assigned_identity_name
  location            = var.location
  resource_group_name = module.appservice_plan.resource_group_name
  tags                = local.tags

  depends_on = [module.appservice_plan]
}

module "webapp" {
  source                              = "../../modules/appservice/webapp"
  rg_name                             = local.resource_names.rg_app
  location                            = var.location
  plan_id                             = module.appservice_plan.plan_id
  acr_id                              = module.acr.id
  acr_login_server                    = module.acr.login_server
  app_name                            = local.resource_names.webapp
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

output "acr_login_server" {
  value = module.acr.login_server
}

output "webapp_name" {
  value = module.webapp.app_name
}
