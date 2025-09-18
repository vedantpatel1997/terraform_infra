# Optional overrides for the azurerm backend defined in backend.tf.
# Copy to backend-config.hcl (ignored by git) if you need to change
# the default values. The identity that runs Terraform must have at
# least the "Storage Blob Data Contributor" role on the storage
# account or container because access keys are disabled.
resource_group_name  = "Wordpress-PHP"
storage_account_name = "storageaccountvp"
container_name       = "tfstate"
key                  = "envs/dev/terraform.tfstate"

# You can uncomment these if you want to pin Terraform to a specific
# subscription or tenant when authenticating via Azure AD/CLI.
# subscription_id = "6a3bb170-5159-4bff-860b-aa74fb762697"
# tenant_id       = "6a3bb170-5159-4bff-860b-aa74fb762697"
