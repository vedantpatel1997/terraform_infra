# Hub-and-Spoke Network Peering with Private DNS Forwarding

## Overview
This repository contains a reusable Terraform implementation of a spoke environment that plugs into an existing hub subscription. Running the configuration builds:

- A spoke virtual network with subnets for App Service integration and private endpoints
- Bidirectional VNet peering to an existing hub virtual network with gateway transit enabled
- Private DNS zones that link back to the hub to centralise name resolution
- Azure Container Registry, App Service plan, user-assigned identity, and two container-based web apps

The goal is to allow any team to deploy an application stack that inherits shared networking services (VPN gateway, Private DNS resolver) provided in the hub subscription.

## Repository Layout
The repo is split into composable Terraform modules and environment-specific entry points:

| Path | Purpose |
|------|---------|
| `envs/dev/` | Example environment. Contains the root Terraform configuration (`main.tf`), provider declarations (`versions.tf`), and environment defaults (`terraform.tfvars`). Copy this folder when creating a new environment. |
| `modules/naming` | Generates consistent resource names based on organisation, project, environment, and location tokens. |
| `modules/network` | Creates the spoke virtual network, subnets, and associated resource group. |
| `modules/private-dns` | Creates Private DNS zones and links them to the spoke and hub VNets. |
| `modules/acr` | Provisions Azure Container Registry with private endpoint integration. |
| `modules/appservice/*` | Contains submodules for the App Service plan and web apps. |

When modifying or extending the infrastructure, update `envs/<environment>/main.tf` to wire additional modules, adjust or override variables in `variables.tf` and `terraform.tfvars`, and add new reusable building blocks under `modules/` as needed.

## Prerequisites
- Terraform CLI `>= 1.7.0`
- Azure CLI `>= 2.50` (used for authentication and role assignments)
- Access to both the spoke and hub Azure subscriptions
- Permission to create Azure AD service principals

## Authentication & Service Principal Requirements
Terraform authenticates with explicit client credentials supplied through variables (`client_id`, `client_secret`, `tenant_id`, and `subscription_id`). The same identity is re-used with provider aliases to operate in the hub subscription.

### 1. Create (or reuse) a service principal for automation
Run once per environment or workload. Replace placeholder values with your own identifiers.

```bash
# Log in with an identity that can create service principals
az login

# Define variables for readability
SPOKE_SUBSCRIPTION="<spoke-subscription-guid>"
HUB_SUBSCRIPTION="<hub-subscription-guid>"
HUB_VNET_SCOPE="/subscriptions/${HUB_SUBSCRIPTION}/resourceGroups/<hub-rg>/providers/Microsoft.Network/virtualNetworks/<hub-vnet-name>"
STATE_SCOPE="/subscriptions/${SPOKE_SUBSCRIPTION}/resourceGroups/<state-rg>/providers/Microsoft.Storage/storageAccounts/<state-storage-account>"
SP_NAME="sp-terraform-hub-spoke"

# Create the service principal with Contributor on the spoke subscription
az ad sp create-for-rbac \
  --name "${SP_NAME}" \
  --role Contributor \
  --scopes "/subscriptions/${SPOKE_SUBSCRIPTION}"
```

Record the `appId`, `password`, and `tenant` values from the output. They correspond to `client_id`, `client_secret`, and `tenant_id` in Terraform.

### 2. Grant required roles on shared resources
The same service principal needs additional rights to interact with hub networking components and (optionally) the remote state storage account.

```bash
# Allow the service principal to manage peering on the hub VNet
az role assignment create \
  --assignee "${SP_NAME}" \
  --role "Network Contributor" \
  --scope "${HUB_VNET_SCOPE}"

# Permit reading VNet information (included in Network Contributor),
# and linking Private DNS zones during deployment
az role assignment create \
  --assignee "${SP_NAME}" \
  --role "Reader" \
  --scope "/subscriptions/${HUB_SUBSCRIPTION}"

# Optional: enable Terraform to read/write state in an Azure Storage container
az role assignment create \
  --assignee "${SP_NAME}" \
  --role "Storage Blob Data Contributor" \
  --scope "${STATE_SCOPE}"
```

> **Summary of required permissions**
>
> - **Spoke subscription:** `Contributor` (allows resource group, network, DNS, and App Service provisioning)
> - **Hub virtual network scope:** `Network Contributor` (allows creation of the hub-to-spoke peering and DNS links)
> - **Hub subscription (optional but recommended):** `Reader` (allows discovery of hub assets through data sources)
> - **Remote state storage (if used):** `Storage Blob Data Contributor`

### 3. Configure Terraform authentication
Provide the captured credentials to Terraform through a `.tfvars` file or environment variables:

```bash
export ARM_CLIENT_ID="<appId>"
export ARM_CLIENT_SECRET="<password>"
export ARM_TENANT_ID="<tenant>"
export ARM_SUBSCRIPTION_ID="${SPOKE_SUBSCRIPTION}"

# Auxiliary tenant IDs allow the provider aliases to request tokens for the hub tenant
export ARM_AUXILIARY_TENANT_IDS="<hub-tenant-guid>"
```

Alternatively, populate `client_id`, `client_secret`, `tenant_id`, `subscription_id`, `hub_subscription_id`, and `hub_tenant_id` directly in `terraform.tfvars`. Avoid committing secrets to version control—use a local `.auto.tfvars` file or environment variables with `terraform apply -var "client_secret=$ARM_CLIENT_SECRET"`.

## Working with Environments
Each environment folder under `envs/` acts as an independent Terraform state. To create a new environment:

1. Copy `envs/dev` to `envs/<new-env>`.
2. Update `terraform.tfvars` with the new subscription IDs, tenant IDs, naming tokens, CIDR ranges, and container image details.
3. Review `variables.tf` for any new variables you might need. Add them to the module interfaces if new functionality is introduced.
4. Modify `main.tf` to add or remove modules/resources for the workload. For example, add a new module block to provision additional private endpoints, or adjust `module "network"` settings to change subnet ranges.

## Running Terraform
The `terraform-commands.txt` file contains an expanded, copy-paste friendly command list. The high-level workflow is:

1. Navigate to the environment folder: `cd envs/dev`
2. (Optional) configure remote state via `backend-config.hcl`
3. Initialise providers and modules: `terraform init`
4. Validate syntax: `terraform validate`
5. Plan changes: `terraform plan -out=tfplan`
6. Apply the saved plan: `terraform apply tfplan`
7. Inspect outputs: `terraform output`
8. Destroy (when needed): `terraform destroy -auto-approve`

## Modifying or Extending the Infrastructure
When new requirements appear:

- **Add a new Azure resource type:** create a module under `modules/` encapsulating that resource, expose variables for customisation, then call the module from `envs/<environment>/main.tf`.
- **Change naming conventions:** update `modules/naming` or provide overrides via the `naming_overrides` variable.
- **Alter networking:** adjust `module "network"` inputs (for example, CIDR ranges) and confirm any dependencies in downstream modules.
- **Adjust application container settings:** change the image repositories, tags, and port numbers in `terraform.tfvars` or promote them to variables if they vary per environment.

Keeping changes modular makes it easier for reviewers and future engineers to understand the blast radius. Whenever you add variables, document them in the README or inline comments, and update `terraform.tfvars` examples so other teams know how to configure new functionality.

## Troubleshooting
- **Authentication failures:** verify the service principal credentials and role assignments. Use `az account get-access-token --resource https://management.azure.com/ --query expiresOn` to ensure the identity can obtain tokens for both tenants.
- **Peering errors:** confirm the hub virtual network scope in the `Network Contributor` role assignment matches the exact hub VNet ID.
- **Private DNS linking issues:** ensure the hub subscription/tenant IDs are correctly set and that the identity has rights to join VNets across tenants.

With these practices, onboarding engineers can confidently understand the deployment topology, authenticate Terraform correctly, and know where to make modifications when introducing new resources.
