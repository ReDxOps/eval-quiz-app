variable "resource_group_name" {
  default = "rg_projet_containers"
}

variable "resource_group_location" {
  default = "switzerlandnorth"
}

variable "tfstate_storage_account_name" {
    default = "tfstateprjcont34343"
}

variable "tfstate_storage_container" {
  default = "tfstate-storage-container"
}

variable "tfstate_storage_account_tier" {
  default = "Standard"
}

variable "tfstate_storage_account_replication_type" {
  default = "LRS"
}

variable "tfstate_storage_container_access_type" {
  default = "private"
}
