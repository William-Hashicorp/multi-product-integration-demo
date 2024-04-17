variable "aws_account_id" {
  type = string
}

variable "stack_id" {
  type        = string
  description = "The name of your stack"
}

variable "tfc_organization" {
  type    = string
}

variable "region" {
  type        = string
  description = "The AWS and HCP region to create resources in"
}

variable "boundary_admin_username" {
  type        = string
  description = "The admin username to be created on the Boundary cluster"
  default     = "admin"
}

variable "boundary_admin_password" {
  type        = string
  description = "The admin user's password on the Boundary cluster"
  sensitive   = true
}

variable "my_email" {
  type = string
  description = "email for the user deploying the stack (required for doormat demo IAM user creation)"
}

variable "nomad_admin" {
  description = "Username for the nomad-admin"
  type        = string
  default     = "nomad-admin"
}

variable "nomad_admin_group" {
  description = "Group name for the nomad-admin"
  type        = string
  default     = "nomad-admins"
}

variable "nomad_admin_role" {
  description = "role name for the nomad-admin"
  type        = string
  default     = "nomad-admin-role"
}


variable "nomad_enduser" {
  description = "Username for the nomad-enduser"
  type        = string
  default     = "nomad-enduser"
}

variable "nomad_enduser_group" {
  description = "Group name for the nomad-enduser"
  type        = string
  default     = "nomad-endusers"
}

variable "nomad_enduser_role" {
  description = "Role name for the nomad-enduser"
  type        = string
  default     = "nomad-enduser-role"
}


variable "auth_method_name" {
  description = "name of the default auth method"
  type        = string
  default     = "password"
}

variable "boundary_org_name" {
  description = "name of the default auth method"
  type        = string
  default     = "demo-org"
}

variable "boundary_project_name" {
  description = "name of the default auth method"
  type        = string
  default     = "hashistack-admin"
}

variable "boundary_signing_algorithms" {
  description = "name of the default auth method"
  type        = string
  default     = "RS256"
}

variable "aad_client_id" {
  description = "The Client ID for Azure AD"
  type        = string
}

variable "aad_client_secret" {
  description = "The Client Secret for Azure AD"
  type        = string
}

variable "aad_issuer" {
  description = "The OIDC issuer for Azure AD"
  type        = string
}

variable "aad_nomad_jit_user_group_id" {
  description = "The Azure AD group ID for the JIT users"
  type        = string
}

variable "aad_nomad_server_admin_group_id" {
  description = "The Azure AD group ID for the Nomad Server admins"
  type        = string
}

variable "aad_email_domain" {
  description = "The email domain for the Azure AD tenant"
  type        = string
  default     = "onmicrosoft.com"
}

# Define the claims_scopes variable
variable "claims_scopes" {
  description = "The scopes of claims to request from the OIDC provider"
  type        = list(string)
  default     = ["profile"] # Default value set as a list with "profile"
}
