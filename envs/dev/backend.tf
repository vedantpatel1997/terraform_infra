terraform {
  backend "azurerm" {
    resource_group_name  = "Wordpress-PHP"
    storage_account_name = "storageaccountvp"
    container_name       = "tfstate"
    key                  = "envs/dev/terraform.tfstate"
    use_azuread_auth     = true
  }
}
