

variable "user_account_name" {
  description = "The User Principal Name (UPN) of the Azure AD User."
  type        = string
}

variable "azuread_group_id" {
  description = "The Object ID of the Azure AD Group."
  type        = string
}
