# Hub-and-Spoke Network Peering with Private DNS Forwarding

## Purpose
This Terraform configuration provisions a spoke virtual network, peering, and application infrastructure that integrates with an existing hub subscription. The spoke VNet is configured to use the hub virtual network gateway for VPN connectivity and the hub Private DNS Resolver for name resolution, ensuring that application private endpoints and DNS traffic remain on the private backbone.

## Multi-tenant Authentication Model
Authenticate to Azure locally (for example, with `az login`) before running Terraform. The configuration reuses your CLI session for **both** the spoke and hub subscriptions via provider aliases (`azurerm.hub` and `azapi.hub`).

- `provider "azurerm"` targets the spoke subscription while honouring your CLI credentials.
- `provider "azurerm" { alias = "hub" }` switches the subscription ID but keeps the same logged-in principal. Auxiliary tenant IDs are configured automatically so cross-tenant peering and Private DNS links succeed when your account is a guest in the hub tenant.

## Running Terraform
1. Navigate to the desired environment folder, e.g. `envs/dev/`.
2. Copy `backend-config.example.hcl` to `backend-config.hcl` and adjust if you use remote state.
3. Provide required values using `terraform.tfvars`, a `.auto.tfvars` file, or environment variables.
4. Initialise providers and modules:
   ```bash
   terraform init [-backend-config=backend-config.hcl]
   ```
5. Review the execution plan:
   ```bash
   terraform plan -out=tfplan
   ```
6. Apply the plan when ready:
   ```bash
   terraform apply tfplan
   ```

## Key Variables
- `subscription_id`, `tenant_id`: Identify the spoke subscription that owns the workload resources.
- `hub_subscription_id`, `hub_tenant_id`: Identify the shared hub subscription. The tenant ID is required when you are a guest user in the hub tenant so Terraform can request auxiliary tokens.
- `hub_resource_group_name`, `hub_vnet_name`: Identify the shared hub network.
- `hub_private_dns_resolver_name`, `hub_private_dns_resolver_inbound_endpoint_name`: Used to query the hub Private DNS Resolver inbound endpoint IPs dynamically. If discovery fails, Terraform falls back to `hub_private_dns_resolver_static_ips` and ultimately to `hub_private_dns_resolver_fallback_ip` (default `11.0.1.68`).
- `spoke_to_hub_peering_name`, `hub_to_spoke_peering_name`: Control peering resource names.

See `envs/dev/terraform.tfvars` for an example of how to populate the identifiers while keeping real secrets external to source control.

## DNS and Networking Flow
1. Terraform peers the spoke VNet to the hub VNet and enables gateway transit so the hub VPN gateway is reused.
2. The spoke VNet DNS servers are set to the Private DNS Resolver inbound endpoint IPs retrieved from the hub (or the configured fallback).
3. Private DNS zones remain owned by the spoke subscription for private endpoint integration, but they link only to the hub VNet. This keeps DNS resolution centralised in the hub while still enabling automatic record creation by private endpoints.

## User Story
> As a developer onboarding a new workload, I want Terraform to set up my spoke environment so that I can deploy applications privately. When I run the configuration, it builds my spoke VNet, peers it with the company hub, points my DNS to the hub resolver, and links any private endpoints back through the hub. After one apply I can connect through the existing VPN and resolve internal resources without exposing anything to the public internet.

With this workflow in place, new engineers sign in with the Azure CLI, supply the required subscription identifiers, run the documented Terraform commands, and gain a fully integrated spoke that respects the organisation's shared hub-and-spoke networking standards.
