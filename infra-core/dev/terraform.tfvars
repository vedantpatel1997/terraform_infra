org_code                              = "contoso"
environment                           = "dev"
location                              = "australiaeast"
vnet_address_space                    = ["10.10.0.0/16"]
client_id                             = "<client-id>"
client_secret                         = "<client-secret>"
spoke_tenant_id                       = "<tenant-id>"
spoke_subscription_id                 = "<subscription-id>"
app_subnet_prefix                     = "10.10.1.0/24"
private_endpoint_subnet_prefix        = "10.10.2.0/24"
hub_subscription_id                   = "00000000-0000-0000-0000-000000000000"
hub_tenant_id                         = "00000000-0000-0000-0000-000000000000"
hub_resource_group_name               = "rg-hub-network"
hub_vnet_name                         = "vnet-hub"
hub_private_dns_resolver_name         = "pdnsr-hub"
hub_private_dns_inbound_endpoint_name = "pdnsr-inbound-hub"

tags = {
  owner = "networking-team"
}
