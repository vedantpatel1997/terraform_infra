locals {
  default_naming_definitions = {
    rg_shared = {
      purpose       = "rg-shared"
      resource_type = "resource_group"
    }
    rg_dns = {
      purpose       = "rg-dns"
      resource_type = "resource_group"
    }
    acr = {
      purpose       = "acr"
      resource_type = "acr"
    }
    storage = {
      purpose       = "stg"
      resource_type = "storage"
    }
    servicebus = {
      purpose    = "sb"
      max_length = 50
    }
    keyvault = {
      purpose       = "kv"
      resource_type = "key_vault"
    }
    sql = {
      purpose    = "sql"
      max_length = 60
    }
    uami_dev = {
      purpose    = "id-dev"
      max_length = 80
    }
    uami_prod = {
      purpose    = "id-prod"
      max_length = 80
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

  resource_names    = module.naming.names
  dns_link_vnet_ids = concat([var.common_vnet_id], var.additional_dns_link_vnet_ids)
}

resource "azurerm_resource_group" "shared" {
  name     = local.resource_names.rg_shared
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "dns" {
  name     = local.resource_names.rg_dns
  location = var.location
  tags     = local.tags
}

module "private_dns" {
  source              = "../../terraform-modules/private-dns"
  resource_group_name = azurerm_resource_group.dns.name
  zones = {
    acr = {
      name            = "privatelink.azurecr.io"
      linked_vnet_ids = local.dns_link_vnet_ids
      tags            = local.tags
    }
    servicebus = {
      name            = "privatelink.servicebus.windows.net"
      linked_vnet_ids = local.dns_link_vnet_ids
      tags            = local.tags
    }
    keyvault = {
      name            = "privatelink.vaultcore.azure.net"
      linked_vnet_ids = local.dns_link_vnet_ids
      tags            = local.tags
    }
    storage_blob = {
      name            = "privatelink.blob.core.windows.net"
      linked_vnet_ids = local.dns_link_vnet_ids
      tags            = local.tags
    }
    sql = {
      name            = "privatelink.database.windows.net"
      linked_vnet_ids = local.dns_link_vnet_ids
      tags            = local.tags
    }
    app_service = {
      name            = "privatelink.azurewebsites.net"
      linked_vnet_ids = local.dns_link_vnet_ids
      tags            = local.tags
    }
  }
}

module "acr" {
  source              = "../../terraform-modules/acr"
  name                = local.resource_names.acr
  resource_group_name = azurerm_resource_group.shared.name
  location            = var.location
  tags                = local.tags
}

module "storage" {
  source              = "../../terraform-modules/storage-account"
  name                = local.resource_names.storage
  resource_group_name = azurerm_resource_group.shared.name
  location            = var.location
  tags                = local.tags
}

module "servicebus" {
  source              = "../../terraform-modules/servicebus"
  name                = local.resource_names.servicebus
  resource_group_name = azurerm_resource_group.shared.name
  location            = var.location
  tags                = local.tags
  queues              = var.servicebus_queues
}

module "keyvault" {
  source              = "../../terraform-modules/keyvault"
  name                = local.resource_names.keyvault
  resource_group_name = azurerm_resource_group.shared.name
  location            = var.location
  tenant_id           = var.tenant_id
  tags                = local.tags
}

module "sql" {
  source                       = "../../terraform-modules/sql"
  name                         = local.resource_names.sql
  resource_group_name          = azurerm_resource_group.shared.name
  location                     = var.location
  administrator_login          = var.sql_administrator_login
  administrator_login_password = var.sql_administrator_password
  databases                    = var.sql_databases
  tags                         = local.tags
}

module "acr_private_endpoint" {
  source              = "../../terraform-modules/private-endpoint"
  name                = format("%s-pe", local.resource_names.acr)
  location            = var.location
  resource_group_name = azurerm_resource_group.shared.name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.tags
  private_service_connection = {
    name                           = format("%s-connection", local.resource_names.acr)
    private_connection_resource_id = module.acr.id
    subresource_names              = ["registry"]
  }
  private_dns_zone_ids = [module.private_dns.zone_ids["acr"]]
}

module "servicebus_private_endpoint" {
  source              = "../../terraform-modules/private-endpoint"
  name                = format("%s-pe", local.resource_names.servicebus)
  location            = var.location
  resource_group_name = azurerm_resource_group.shared.name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.tags
  private_service_connection = {
    name                           = format("%s-connection", local.resource_names.servicebus)
    private_connection_resource_id = module.servicebus.namespace_id
    subresource_names              = ["namespace"]
  }
  private_dns_zone_ids = [module.private_dns.zone_ids["servicebus"]]
}

module "keyvault_private_endpoint" {
  source              = "../../terraform-modules/private-endpoint"
  name                = format("%s-pe", local.resource_names.keyvault)
  location            = var.location
  resource_group_name = azurerm_resource_group.shared.name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.tags
  private_service_connection = {
    name                           = format("%s-connection", local.resource_names.keyvault)
    private_connection_resource_id = module.keyvault.id
    subresource_names              = ["vault"]
  }
  private_dns_zone_ids = [module.private_dns.zone_ids["keyvault"]]
}

module "storage_private_endpoint" {
  source              = "../../terraform-modules/private-endpoint"
  name                = format("%s-pe", local.resource_names.storage)
  location            = var.location
  resource_group_name = azurerm_resource_group.shared.name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.tags
  private_service_connection = {
    name                           = format("%s-connection", local.resource_names.storage)
    private_connection_resource_id = module.storage.id
    subresource_names              = ["blob"]
  }
  private_dns_zone_ids = [module.private_dns.zone_ids["storage_blob"]]
}

module "sql_private_endpoint" {
  source              = "../../terraform-modules/private-endpoint"
  name                = format("%s-pe", local.resource_names.sql)
  location            = var.location
  resource_group_name = azurerm_resource_group.shared.name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.tags
  private_service_connection = {
    name                           = format("%s-connection", local.resource_names.sql)
    private_connection_resource_id = module.sql.server_id
    subresource_names              = ["sqlServer"]
  }
  private_dns_zone_ids = [module.private_dns.zone_ids["sql"]]
}

locals {
  dev_role_assignments = [
    {
      scope                = module.acr.id
      role_definition_name = "AcrPull"
    },
    {
      scope                = module.storage.id
      role_definition_name = "Storage Blob Data Reader"
    },
    {
      scope                = module.keyvault.id
      role_definition_name = "Key Vault Secrets User"
    },
    {
      scope                = module.servicebus.namespace_id
      role_definition_name = "Azure Service Bus Data Sender"
    },
    {
      scope                = module.servicebus.namespace_id
      role_definition_name = "Azure Service Bus Data Receiver"
    },
    {
      scope                = lookup(module.sql.database_ids, "dev")
      role_definition_name = "SQL DB Contributor"
    }
  ]

  prod_role_assignments = [
    {
      scope                = module.acr.id
      role_definition_name = "AcrPull"
    },
    {
      scope                = module.storage.id
      role_definition_name = "Storage Blob Data Reader"
    },
    {
      scope                = module.keyvault.id
      role_definition_name = "Key Vault Secrets User"
    },
    {
      scope                = module.servicebus.namespace_id
      role_definition_name = "Azure Service Bus Data Sender"
    },
    {
      scope                = module.servicebus.namespace_id
      role_definition_name = "Azure Service Bus Data Receiver"
    },
    {
      scope                = lookup(module.sql.database_ids, "prod")
      role_definition_name = "SQL DB Contributor"
    }
  ]
}

module "uami_dev" {
  source              = "../../terraform-modules/uami"
  name                = local.resource_names.uami_dev
  location            = var.location
  resource_group_name = azurerm_resource_group.shared.name
  tags                = local.tags
  role_assignments    = local.dev_role_assignments
}

module "uami_prod" {
  source              = "../../terraform-modules/uami"
  name                = local.resource_names.uami_prod
  location            = var.location
  resource_group_name = azurerm_resource_group.shared.name
  tags                = local.tags
  role_assignments    = local.prod_role_assignments
}
