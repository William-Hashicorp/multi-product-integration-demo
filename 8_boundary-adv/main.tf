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
      //version = "~> 1.1.9"
      version = "~> 1.1.14"
    }

    vault = {
      source = "hashicorp/vault"
      version = "~> 3.18.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.98.0"
    }

  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
}


data "terraform_remote_state" "hcp_clusters" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "2_hcp-clusters"
    }
  }
}

data "terraform_remote_state" "boundary_configs" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "4_boundary-config"
    }
  }
}

data "terraform_remote_state" "nomad_configs" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "5_nomad-cluster"
    }
  }
}


provider "vault" {}

provider "boundary" {
  addr  = data.terraform_remote_state.hcp_clusters.outputs.boundary_public_endpoint
  auth_method_login_name = var.boundary_admin_username
  auth_method_password   = var.boundary_admin_password
}




resource "boundary_scope" "global" {
  global_scope = true
  scope_id     = "global"
}


data "boundary_scope" "org" {
  name                     = var.boundary_org_name
  scope_id                 = "global"
}


data "boundary_scope" "project" {
  name                   = var.boundary_project_name
  scope_id               = data.boundary_scope.org.id 
}

data "boundary_auth_method" "password" {
  scope_id = boundary_scope.global.id
  name     = var.auth_method_name
}

# Create accounts
resource "boundary_account_password" "nomad_admin_account" {
  name           = var.nomad_admin
  description    = "Account for Nomad Admin"
  login_name     = var.nomad_admin
  password       = var.boundary_admin_password
  auth_method_id = data.boundary_auth_method.password.id
}

resource "boundary_account_password" "nomad_enduser_account" {
  name           = var.nomad_enduser
  description    = "Account for Nomad End User"
  login_name     = var.nomad_enduser
  password       = var.boundary_admin_password
  auth_method_id = data.boundary_auth_method.password.id
}

# Create users
resource "boundary_user" "nomad_admin" {
  name        = var.nomad_admin
  description = "Nomad Admin User"
  scope_id    = boundary_scope.global.id
  account_ids = [boundary_account_password.nomad_admin_account.id]
}

resource "boundary_user" "nomad_enduser" {
  name        = var.nomad_enduser
  description = "Nomad End User"
  scope_id    = boundary_scope.global.id
  account_ids = [boundary_account_password.nomad_enduser_account.id]
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

# Create global level roles with grants
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

# Create org level roles with grants
# Role for Nomad Admins
resource "boundary_role" "org_nomad_admin_role" {
  name          = var.nomad_admin_role
  description   = "Role for Nomad Admins"
  scope_id      = data.boundary_scope.org.id 
  principal_ids = [
    boundary_group.nomad_admins.id,
    boundary_managed_group.normad_admin_users.id
  ] 
  grant_strings = [
    "ids=*;type=*;actions=read,list",
  ]
}

# Role for Nomad End Users
resource "boundary_role" "org_nomad_enduser_role" {
  name          = var.nomad_enduser_role
  description   = "Role for Nomad End Users"
  scope_id      = data.boundary_scope.org.id 
  principal_ids = [
    boundary_group.nomad_endusers.id,  # normal group
    boundary_managed_group.jitusers.id # JIT Users managed group
    ] 
  grant_strings = [
    "ids=*;type=*;actions=read,list",
  ]
}

# Create project level roles with grants
# Role for Nomad Admins
resource "boundary_role" "project_nomad_admin_role" {
  name          = var.nomad_admin_role
  description   = "Role for Nomad Admins in project hashistack-admin"
  scope_id      = data.boundary_scope.project.id
  principal_ids = [
    boundary_group.nomad_admins.id,
    boundary_managed_group.normad_admin_users.id
    ]

  grant_strings = [
    "ids=${data.terraform_remote_state.boundary_configs.outputs.nomad_servers_target_id};actions=read,authorize-session",
    "ids=*;type=session;actions=read,read:self,cancel,cancel:self,no-op,list",
    "ids=*;type=target;actions=list",
    "ids=*;type=host-set;actions=list,read",
    "ids=*;type=host-catalog;actions=list,read",
    "ids=*;type=host;actions=list,read",
  ]
}

# Role for Nomad End users

resource "boundary_role" "project_nomad_enduser_role" {
  name          = var.nomad_enduser_role
  description   = "Role for Nomad End Users"
  scope_id      = data.boundary_scope.project.id  # Ensure this is your intended scope
  principal_ids = [
    boundary_group.nomad_endusers.id,  # normal group 
    boundary_managed_group.jitusers.id # JIT Users managed group
    ]  

  grant_strings = [
    "ids=${data.terraform_remote_state.boundary_configs.outputs.nomad_nodes_x86_target_id},${data.terraform_remote_state.boundary_configs.outputs.nomad_nodes_arm_target_id};actions=read,authorize-session",
    "ids=*;type=session;actions=read,read:self,cancel,cancel:self,no-op,list",
    "ids=*;type=target;actions=list",
    "ids=*;type=host-set;actions=list,read",
    "ids=*;type=host-catalog;actions=list,read",
    "ids=*;type=host;actions=list,read",
  ]
}

# Create an OIDC auth method
resource "boundary_auth_method_oidc" "oidc_auth" {
  name          = "oidc" # You can change this to your preferred name
  description   = "OIDC auth method for Azure AD"
  # We can only enable oidc on org level. If we enable on Global level, 
  # it will impact boundary provider after making oidc as primary
  # because boundary provider only support authentication with password.
  scope_id      = data.boundary_scope.org.id 

  issuer        = var.aad_issuer
  client_id     = var.aad_client_id
  client_secret = var.aad_client_secret
  api_url_prefix = data.terraform_remote_state.hcp_clusters.outputs.boundary_public_endpoint
  # this is to force user logoff from boundary client/portal after OIDC auth.
  # Rhe managed group membership will only be refreshed after the user login again.
  max_age = 300
  # make oidc as the primary auth method for the scope in which it resides. 
  # The primary auth method for a scope means the user will be automatically created when they login using an OIDC account.
  is_primary_for_scope = true
  type = "oidc"
 
  # Configuration for OIDC
  signing_algorithms = [var.boundary_signing_algorithms]

  # Configuration for claims scopes
  claims_scopes = var.claims_scopes

  # Additional configuration like allowed_audiences, claim_mappings, etc., can be added here
}

# Managed Group for All Azure Users with onmicrosoft.com domain in email
resource "boundary_managed_group" "azure_all_users" {
  name        = "Azure-All-Users"
  description = "All users with onmicrosoft.com domain in email"
  auth_method_id = boundary_auth_method_oidc.oidc_auth.id
  
  # Filter expression for users with onmicrosoft.com domain in their email
  filter = "\"${var.aad_email_domain}\" in \"/token/email\""
}

# Managed Group for Users Member of a nomad jit users Group
resource "boundary_managed_group" "jitusers" {
  name        = "jitusers"
  description = "Users who are members of a specific Azure AD group jitusers"
  auth_method_id = boundary_auth_method_oidc.oidc_auth.id
  
  # Filter for members of the group with a specific ID
  filter = "\"${var.aad_nomad_jit_user_group_id}\" in \"/token/groups\""
}

# Managed Group for Member of a nomad server admin Group
resource "boundary_managed_group" "normad_admin_users" {
  name        = "normad_admin_users"
  description = "Users who are members of a specific Azure AD group nomad-server-admins "
  auth_method_id = boundary_auth_method_oidc.oidc_auth.id
  
  # Filter for members of the group with a specific ID
  filter = "\"${var.aad_nomad_server_admin_group_id}\" in \"/token/groups\""
}
