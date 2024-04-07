# Output the ID of the created auth method
output "oidc_auth_method_id" {
  value = boundary_auth_method_oidc.oidc_auth.id
}