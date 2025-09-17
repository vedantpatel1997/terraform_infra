locals {
  default_app_settings = {
    WEBSITES_PORT = tostring(var.container_port)
  }
}

resource "azurerm_linux_web_app" "this" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.rg_name
  service_plan_id     = var.plan_id
  https_only          = true
  tags                = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  site_config {
    always_on                                     = true
    ftps_state                                    = "Disabled"
    minimum_tls_version                           = "1.2"
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = var.user_assigned_identity_client_id

    application_stack {
      docker_image_name   = "${var.image_repository}:${var.image_tag}"
      docker_registry_url = "https://${var.acr_login_server}"
    }
  }

  app_settings = merge(local.default_app_settings, var.app_settings)

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
  }

  virtual_network_subnet_id = var.appsvc_integration_subnet_id
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.user_assigned_identity_principal_id
}

resource "azurerm_private_endpoint" "web" {
  name                = "${var.app_name}-pep-web"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.pe_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.app_name}-web"
    private_connection_resource_id = azurerm_linux_web_app.this.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "webapp-dns"
    private_dns_zone_ids = [var.web_zone_id]
  }
}

