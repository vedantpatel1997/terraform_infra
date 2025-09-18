locals {
  raw_custom_tokens = {
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
    identity = {
      purpose    = format("id-%s", local.sanitized_custom_tokens.identity_purpose)
      max_length = 80
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

data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_resource_group_name

  provider = azurerm.hub
}

data "azurerm_role_definition" "network_contributor" {
  name  = "Network Contributor"
  scope = data.azurerm_virtual_network.hub.id

  provider = azurerm.hub
}

data "azapi_resource" "hub_private_dns_inbound_endpoint" {
  count = var.hub_private_dns_resolver_name != null && var.hub_private_dns_resolver_inbound_endpoint_name != null ? 1 : 0

  type      = "Microsoft.Network/dnsResolvers/inboundEndpoints@2023-07-01"
  name      = var.hub_private_dns_resolver_inbound_endpoint_name
  parent_id = format(
    "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/dnsResolvers/%s",
    var.hub_subscription_id,
    var.hub_resource_group_name,
    var.hub_private_dns_resolver_name,
  )

  provider = azapi.hub
}

locals {
  hub_dns_inbound_ip_configurations = length(data.azapi_resource.hub_private_dns_inbound_endpoint) > 0 ? try(
    jsondecode(data.azapi_resource.hub_private_dns_inbound_endpoint[0].output).properties.ipConfigurations,
    [],
  ) : []

  hub_dns_inbound_ips_dynamic = [
    for config in local.hub_dns_inbound_ip_configurations : config.privateIpAddress
    if try(config.privateIpAddress, null) != null
  ]

  hub_dns_servers = coalescelist(
    local.hub_dns_inbound_ips_dynamic,
    var.hub_private_dns_resolver_static_ips,
    [var.hub_private_dns_resolver_fallback_ip],
  )
}

module "network" {
  source             = "../../modules/network"
  rg_name            = local.resource_names.rg_network
  location           = var.location
  vnet_name          = local.resource_names.vnet
  vnet_address_space = [var.vnet_cidr]
  dns_servers        = local.hub_dns_servers
  env                = module.naming.tokens.environment
  appsvc_subnet = {
    name   = local.resource_names.snet_appsvc
    prefix = var.snet_appsvc_cidr
  }
  private_endpoint_subnet = {
    name   = local.resource_names.snet_private_endpoint
    prefix = var.snet_pe_cidr
  }
  tags = local.tags
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = var.spoke_to_hub_peering_name
  resource_group_name       = local.resource_names.rg_network
  virtual_network_name      = local.resource_names.vnet
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true

  depends_on = [module.network]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = var.hub_to_spoke_peering_name
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = module.network.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true

  provider = azurerm.hub

  depends_on = [module.network]
}


resource "azurerm_role_assignment" "hub_vnet_access_for_spoke_sp" {
  scope              = data.azurerm_virtual_network.hub.id
  role_definition_id = data.azurerm_role_definition.network_contributor.id
  principal_id       = var.spoke_client_object_id
  principal_type     = "ServicePrincipal"

  provider = azurerm.hub
}


module "dns" {
  source    = "../../modules/private-dns"
  rg_name   = local.resource_names.rg_dns
  location  = var.location
  vnet_id   = module.network.vnet_id
  vnet_name = local.resource_names.vnet
  linked_vnet_ids = [data.azurerm_virtual_network.hub.id]
  tags      = local.tags

  depends_on = [
    azurerm_role_assignment.hub_vnet_access_for_spoke_sp,
  ]
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

module "webapp_frontend" {
  source                              = "../../modules/appservice/webapp"
  rg_name                             = local.resource_names.rg_app
  location                            = var.location
  plan_id                             = module.appservice_plan.plan_id
  acr_id                              = module.acr.id
  acr_login_server                    = module.acr.login_server
  app_name                            = local.resource_names.webapp_frontend
  image_repository                    = var.frontend_image_repository
  image_tag                           = var.frontend_image_tag
  container_port                      = var.frontend_container_port
  appsvc_integration_subnet_id        = module.network.appsvc_integration_snet_id
  pe_subnet_id                        = module.network.pe_snet_id
  web_zone_id                         = module.dns.web_zone_id
  app_settings                        = {}
  user_assigned_identity_id           = azurerm_user_assigned_identity.webapp.id
  user_assigned_identity_client_id    = azurerm_user_assigned_identity.webapp.client_id
  user_assigned_identity_principal_id = azurerm_user_assigned_identity.webapp.principal_id
  tags                                = local.tags
}

module "webapp_backend" {
  source                              = "../../modules/appservice/webapp"
  rg_name                             = local.resource_names.rg_app
  location                            = var.location
  plan_id                             = module.appservice_plan.plan_id
  acr_id                              = module.acr.id
  acr_login_server                    = module.acr.login_server
  app_name                            = local.resource_names.webapp_backend
  image_repository                    = var.backend_image_repository
  image_tag                           = var.backend_image_tag
  container_port                      = var.backend_container_port
  appsvc_integration_subnet_id        = module.network.appsvc_integration_snet_id
  pe_subnet_id                        = module.network.pe_snet_id
  web_zone_id                         = module.dns.web_zone_id
  app_settings                        = {}
  user_assigned_identity_id           = azurerm_user_assigned_identity.webapp.id
  user_assigned_identity_client_id    = azurerm_user_assigned_identity.webapp.client_id
  user_assigned_identity_principal_id = azurerm_user_assigned_identity.webapp.principal_id
  enable_acr_pull_role_assignment     = false
  tags                                = local.tags
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "frontend_webapp_name" {
  value = module.webapp_frontend.app_name
}

output "backend_webapp_name" {
  value = module.webapp_backend.app_name
}
