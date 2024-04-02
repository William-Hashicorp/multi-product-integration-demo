terraform {
  required_providers {
    doormat = {
      source  = "doormat.hashicorp.services/hashicorp-security/doormat"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }

    boundary = {
      source = "hashicorp/boundary"
      version = "~> 1.1.9"
    }

    vault = {
      source = "hashicorp/vault"
      version = "~> 3.18.0"
    }
  }
}

# provider "doormat" {}

# data "doormat_aws_credentials" "creds" {
#   provider = doormat
#   role_arn = "arn:aws:iam::${var.aws_account_id}:role/tfc-doormat-role_4_boundary-config"
# }

# provider "aws" {
#   region     = var.region
#   access_key = data.doormat_aws_credentials.creds.access_key
#   secret_key = data.doormat_aws_credentials.creds.secret_key
#   token      = data.doormat_aws_credentials.creds.token
# }

data "terraform_remote_state" "hcp_clusters" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "2_hcp-clusters"
    }
  }
}

provider "vault" {}

provider "boundary" {
  addr  = data.terraform_remote_state.hcp_clusters.outputs.boundary_public_endpoint
  auth_method_login_name = var.boundary_admin_username
  auth_method_password   = var.boundary_admin_password
}




# data "boundary_scope" "global" {
#   name = "global"
#   scope_id     = ""
# }

resource "boundary_scope" "global" {
  global_scope = true
  scope_id     = "global"
}


data "boundary_scope" "org" {
  name                     = "demo-org"
  scope_id                 = "global"
}


data "boundary_scope" "project" {
  name                   = "hashistack-admin"
  scope_id               = data.boundary_scope.org.id 
}

data "boundary_auth_method" "password" {
  scope_id = boundary_scope.global.id
  name     = var.auth_method_name
}

# Create accounts
resource "boundary_account" "nomad_admin_account" {
  name           = var.nomad_admin
  description    = "Account for Nomad Admin"
  type           = "password"
  login_name     = var.nomad_admin
  password       = var.boundary_admin_password
  auth_method_id = data.boundary_auth_method.password.id
}

resource "boundary_account" "nomad_enduser_account" {
  name           = var.nomad_enduser
  description    = "Account for Nomad End User"
  type           = "password"
  login_name     = var.nomad_enduser
  password       = var.boundary_admin_password
  auth_method_id = data.boundary_auth_method.password.id
}

# Create users
resource "boundary_user" "nomad_admin" {
  name        = var.nomad_admin
  description = "Nomad Admin User"
  scope_id    = boundary_scope.global.id
  account_ids = [boundary_account.nomad_admin_account.id]
}

resource "boundary_user" "nomad_enduser" {
  name        = var.nomad_enduser
  description = "Nomad End User"
  scope_id    = boundary_scope.global.id
  account_ids = [boundary_account.nomad_enduser_account.id]
}


# Create groups
resource "boundary_group" "nomad_admins" {
  name        = var.nomad_admin_group
  description = "Group for Nomad Admins"
  scope_id    = boundary_scope.global.id
  member_ids  = [boundary_user.nomad_admin.id]
}

resource "boundary_group" "nomad_endusers" {
  name        = var.nomad_enduser_group
  description = "Group for Nomad End Users"
  scope_id    = boundary_scope.global.id
  member_ids  = [boundary_user.nomad_enduser.id]
}

# Create roles with grants
resource "boundary_role" "nomad_admin_role" {
  name          = var.nomad_admin_role
  description   = "Role for Nomad Admins"
  scope_id      = boundary_scope.global.id
  principal_ids = [boundary_group.nomad_admins.id]
  grant_strings = [
    "ids=*;type=*;actions=read,list"
  ]
}

resource "boundary_role" "nomad_enduser_role" {
  name          = var.nomad_enduser_role
  description   = "Role for Nomad End Users"
  scope_id      = boundary_scope.global.id
  principal_ids = [boundary_group.nomad_endusers.id]
  grant_strings = [
    "ids=*;type=*;actions=read,list"
  ]
}
