# Terraform Hub-and-Spoke Reference with Shared Services and UAMIs

## Overview
This repository implements a reusable hub-and-spoke topology for Azure workloads.  It mirrors the reference architecture described
in the "Terraform Architecture & Management Guide" and is split into three logical layers:

* **infra-core** – builds the spoke virtual networks for dev/prod and the common services network, including hub peerings.
* **infra-shared** – provisions shared services (ACR, Service Bus, Storage, Key Vault, SQL) inside the common VNet and hosts
  private DNS zones.  It also creates environment-specific user-assigned managed identities (UAMIs) with scoped RBAC.
* **infra-apps** – deploys application runtimes (example App Services) per environment and binds them to the shared UAMIs while
  consuming outputs published by `infra-shared` and `infra-core`.

Reusable building blocks live under `terraform-modules/` and expose composable modules for VNets, private DNS, shared services,
managed identities, private endpoints, and App Service resources.

## Repository Layout

| Path | Purpose |
|------|---------|
| `infra-core/common` | Creates the common VNet that hosts private endpoints and shared DNS zones. |
| `infra-core/dev` / `infra-core/prod` | Create environment-specific spoke VNets, subnets, and hub peerings. |
| `infra-shared/common` | Deploys shared services in the common VNet, configures private endpoints/DNS, and provisions the dev/prod UAMIs. |
| `infra-apps/dev` / `infra-apps/prod` | Deploy example App Service workloads that attach to the shared registry, DNS, and UAMIs. |
| `terraform-modules/` | Versioned modules reused across layers (naming, vnet, private DNS, ACR, Key Vault, SQL, Service Bus, storage, UAMI, private endpoint, App Service, etc.). |
| `terraform-commands.txt` | Convenience commands for Terraform workflows. |

Each folder under `infra-*` is a standalone Terraform state.  Configure its backend independently (for example via `backend.tf` or
CLI flags) so that dev/prod/common states remain isolated as described in the architecture guide.

## Deployment Workflow

1. **Core networking (`infra-core`)**
   * Deploy `infra-core/common` to create the shared VNet and private-endpoint subnet.
   * Deploy `infra-core/dev` and `infra-core/prod` to create the spoke VNets and peer them with the hub VNet.  Provide the hub
     subscription/resource-group/VNet names and optional DNS server IPs if you use a Private DNS resolver in the hub.
2. **Shared services (`infra-shared/common`)**
   * Pass the common VNet ID and private-endpoint subnet ID from the previous step.
   * Supply the SQL administrator credentials (values should come from a secure secret store) and the tenant ID for Key Vault.
   * The module outputs registry IDs, SQL/database IDs, Service Bus namespace information, storage/Key Vault identifiers, DNS zone
     IDs, and the dev/prod UAMI properties.
3. **Application layers (`infra-apps/dev` and `/prod`)**
   * Consume outputs from `infra-core` and `infra-shared` (for example via `terraform_remote_state`).
   * Provide container image metadata per environment.  The sample configuration deploys frontend/backend Web Apps that use
     the shared UAMI to authenticate against ACR, Key Vault, Service Bus, Storage, and SQL.

## Remote State
Store Terraform state in an Azure Storage account with soft-delete/versioning enabled.  A common pattern is to create a `tfstate`
container and configure each layer to use a dedicated blob path, e.g. `core/dev.tfstate`, `shared/common.tfstate`, `apps/dev.tfstate`, etc.
Refer to the architecture guide for detailed recommendations on state isolation, locking, and automation pipelines.

## Prerequisites

* Terraform CLI `>= 1.7.0`
* Azure CLI `>= 2.50.0`
* Permissions to deploy resources in the spoke subscription(s) and read/peer with the hub subscription
* Credentials to create the SQL administrator account and assign RBAC roles for UAMIs

Authenticate with Azure via `az login` or by exporting the standard `ARM_*` environment variables before running Terraform.

## Running Terraform

Each environment folder is independent.  Example workflow for the dev application stack:

```bash
cd infra-core/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan

cd ../../infra-shared/common
terraform init
terraform plan -out=tfplan
terraform apply tfplan

cd ../../infra-apps/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Repeat for `prod` where appropriate.  Pipelines should run `terraform fmt`, `terraform validate`, and `terraform plan` on pull
requests, promote plans for approval, and run nightly drift detection using `terraform plan -detailed-exitcode`.

## Extending the Modules

* Add new shared services by creating a module under `terraform-modules/` and wiring it into `infra-shared/common`.
* Extend the VNet module to include NSGs/route tables if additional segmentation is required.
* Introduce new application runtimes (AKS, Container Apps, Functions) under `infra-apps/` by reusing the provided modules and
  attaching the appropriate environment-specific UAMI.

Keep RBAC assignments, network policies, and naming standards codified in Terraform so that dev/prod remain isolated while sharing
central services through the common VNet.
