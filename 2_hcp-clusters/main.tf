terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.99.0"
    }
  }
}

provider "hcp" {}


data "terraform_remote_state" "networking" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "1_networking"
    }
  }
}

resource "hcp_vault_cluster" "hashistack" {
  cluster_id      = "${var.stack_id}-vault-cluster"
  hvn_id          = data.terraform_remote_state.networking.outputs.hvn_id
  tier            = var.vault_cluster_tier
  public_endpoint = true
}

resource "hcp_consul_cluster" "hashistack" {
  cluster_id      = "${var.stack_id}consul-cluster"
  hvn_id          = data.terraform_remote_state.networking.outputs.hvn_id
  tier            = var.consul_cluster_tier
  public_endpoint = true
  connect_enabled = true
}

resource "hcp_boundary_cluster" "hashistack" {
  cluster_id = "${var.stack_id}-boundary-cluster"
  tier       = var.boundary_cluster_tier
  username   = var.boundary_admin_username
  password   = var.boundary_admin_password
}

resource "null_resource" "recreate_trigger" {
  depends_on = [ hcp_consul_cluster.hashistack, hcp_vault_cluster.hashistack ]
  // This triggers block causes the resource to be recreated everytime.
  triggers = {
    the_trigger_recreate_null_resource = "${timestamp()}"
  }
}

# consul admin token will be recreated every time to avoid expiration.
resource "hcp_consul_cluster_root_token" "provider" {
  depends_on = [ hcp_consul_cluster.hashistack, null_resource.recreate_trigger ]
  cluster_id = hcp_consul_cluster.hashistack.cluster_id
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    replace_triggered_by = [null_resource.recreate_trigger.id]
  }
}

# vault admin token will be recreated every time to avoid expiration.
resource "hcp_vault_cluster_admin_token" "provider" {
  depends_on = [ hcp_vault_cluster.hashistack, null_resource.recreate_trigger ]
  cluster_id = hcp_vault_cluster.hashistack.cluster_id
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    replace_triggered_by = [null_resource.recreate_trigger.id]
  }
}
