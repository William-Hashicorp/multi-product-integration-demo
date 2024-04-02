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
