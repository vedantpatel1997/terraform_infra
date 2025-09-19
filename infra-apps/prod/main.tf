locals {
  default_naming_definitions = {
    rg_app = {
      purpose       = "rg-apps"
      resource_type = "resource_group"
    }
    appservice_plan = {
      purpose    = "plan"
      max_length = 40
    }
    webapp_frontend = {
      purpose    = "app-frontend"
      max_length = 60
    }
    webapp_backend = {
      purpose    = "app-backend"
      max_length = 60
    }
  }

  naming_definitions = merge(local.default_naming_definitions, var.naming_overrides)
}

module "naming" {
  source               = "../../terraform-modules/naming"
  org_code             = var.org_code
  project_code         = var.project_code
  environment          = var.environment
  location             = var.location
  resource_definitions = local.naming_definitions
}

locals {
  tags = merge({
    environment = module.naming.tokens.environment,
    location    = module.naming.tokens.location,
    workload    = module.naming.tokens.project,
  }, var.tags)

  resource_names = module.naming.names
}

module "appservice_plan" {
  source    = "../../terraform-modules/appservice/plan"
  rg_name   = local.resource_names.rg_app
  location  = var.location
  plan_name = local.resource_names.appservice_plan
  plan_sku  = var.plan_sku
  tags      = local.tags
}

module "frontend_webapp" {
  source                              = "../../terraform-modules/appservice/webapp"
  rg_name                             = module.appservice_plan.resource_group_name
  location                            = var.location
  plan_id                             = module.appservice_plan.plan_id
  acr_id                              = var.acr_id
  acr_login_server                    = var.acr_login_server
  app_name                            = local.resource_names.webapp_frontend
  image_repository                    = var.frontend_image_repository
  image_tag                           = var.frontend_image_tag
  container_port                      = var.frontend_container_port
  appsvc_integration_subnet_id        = var.appsvc_subnet_id
  pe_subnet_id                        = var.private_endpoint_subnet_id
  web_zone_id                         = var.web_private_dns_zone_id
  app_settings                        = var.frontend_app_settings
  user_assigned_identity_id           = var.uami_id
  user_assigned_identity_client_id    = var.uami_client_id
  user_assigned_identity_principal_id = var.uami_principal_id
  enable_acr_pull_role_assignment     = false
  tags                                = local.tags
}

module "backend_webapp" {
  source                              = "../../terraform-modules/appservice/webapp"
  rg_name                             = module.appservice_plan.resource_group_name
  location                            = var.location
  plan_id                             = module.appservice_plan.plan_id
  acr_id                              = var.acr_id
  acr_login_server                    = var.acr_login_server
  app_name                            = local.resource_names.webapp_backend
  image_repository                    = var.backend_image_repository
  image_tag                           = var.backend_image_tag
  container_port                      = var.backend_container_port
  appsvc_integration_subnet_id        = var.appsvc_subnet_id
  pe_subnet_id                        = var.private_endpoint_subnet_id
  web_zone_id                         = var.web_private_dns_zone_id
  app_settings                        = var.backend_app_settings
  user_assigned_identity_id           = var.uami_id
  user_assigned_identity_client_id    = var.uami_client_id
  user_assigned_identity_principal_id = var.uami_principal_id
  enable_acr_pull_role_assignment     = false
  tags                                = local.tags
}
