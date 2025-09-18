# Copy this file to set-sp-credentials.ps1 and update the placeholder values
# with your multi-tenant service principal credentials before running
# Terraform commands. The script sets the environment variables used by
# both the azurerm backend and providers to authenticate.

$env:ARM_USE_AZUREAD      = "true"
$env:ARM_CLIENT_ID        = "<app-id>"
$env:ARM_CLIENT_SECRET    = "<client-secret>"
$env:ARM_TENANT_ID        = "<spoke-tenant-id>"
$env:ARM_SUBSCRIPTION_ID  = "6a3bb170-5159-4bff-860b-aa74fb762697"
$env:ARM_AUXILIARY_TENANT_IDS = "f913f484-b59e-49a4-95ce-feddd38dc57a"
