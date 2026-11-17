terraform {
  backend "azurerm" {
    resource_group_name  = "rg_projet_containers"
    storage_account_name = "tfstateprjcont34343"
    container_name       = "tfstate-storage-container"
    key                  = "prod.terraform.tfstate"
  }
}
