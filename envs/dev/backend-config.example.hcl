# Optional overrides for the azurerm backend defined in backend.tf.
# Copy to backend-config.hcl (ignored by git) if you need to change
# the default values. The identity that runs Terraform must have at
# least the "Storage Blob Data Contributor" role on the storage
# account or container because access keys are disabled.
resource_group_name  = "Wordpress-PHP"
storage_account_name = "storageaccountvp"
container_name       = "tfstate"
key                  = "envs/dev/terraform.tfstate"
use_azuread_auth     = true

# When authenticating with the shared multi-tenant service principal,
# populate these fields with the same values you export via the
# set-sp-credentials.ps1 helper script before running terraform init.
#client_id        = "<app-id>"
#client_secret    = "<client-secret>"
#tenant_id        = "<spoke-tenant-id>"
#subscription_id  = "6a3bb170-5159-4bff-860b-aa74fb762697"
