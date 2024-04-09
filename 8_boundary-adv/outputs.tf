# Output the ID of the created auth method
output "oidc_auth_method_id" {
  value = boundary_auth_method_oidc.oidc_auth.id
}

output "boundary_public_endpoint" {
  value = data.terraform_remote_state.hcp_clusters.outputs.boundary_public_endpoint
}

output "vault_public_endpoint" {
  value = data.terraform_remote_state.hcp_clusters.outputs.vault_public_endpoint
}

output "consul_public_endpoint" {
  value = data.terraform_remote_state.hcp_clusters.outputs.consul_public_endpoint
}