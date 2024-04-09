# this code is to be run by ServiceNow to add/remove users from AAD groups.
terraform {
required_providers {
    azuread = {
        source  = "hashicorp/azuread"
        version = "~> 2.47.0"
    }
}
}

provider "azuread" {}

data "azuread_user" "aad_user" {
  user_principal_name = var.aad_user_principal_name
}

resource "azuread_group_member" "aad_group_member" {
  group_object_id  = var.aad_group_id
  member_object_id = data.azuread_user.aad_user.object_id
}



