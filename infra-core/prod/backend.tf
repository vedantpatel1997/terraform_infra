terraform {
  backend "azurerm" {
    resource_group_name  = "TerraformStorageAccount"
    storage_account_name = "terrsaform"
    container_name       = "terraform"
    key                  = "infra-core/prod/terraform.tfstate"
  }
}
