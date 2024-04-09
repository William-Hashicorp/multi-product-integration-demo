variable "client_id" {
  description = "The Client ID of the Azure Service Principal."
  type        = string
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal."
  type        = string
}

variable "tenant_id" {
  description = "The Tenant ID of the Azure AD."
  type        = string
}

variable "user_account_name" {
  description = "The User Principal Name (UPN) of the Azure AD User."
  type        = string
}

variable "azuread_group_id" {
  description = "The Object ID of the Azure AD Group."
  type        = string
}
