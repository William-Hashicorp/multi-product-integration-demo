terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.66.0"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
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
  cluster_id      = "${var.stack_id}-consul-cluster"
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

resource "random_pet" "trigger" {
  length = 1
}

resource "null_resource" "recreate_trigger" {
  // This triggers block causes the resource to be recreated any time the random_pet's id changes.
  triggers = {
    pet_id = random_pet.trigger.id
  }

}

resource "hcp_consul_cluster_root_token" "provider" {
  cluster_id = hcp_consul_cluster.hashistack.cluster_id
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }

  # Dummy dependency to force recreation  
  depends_on = [random_pet.trigger]
}



resource "hcp_vault_cluster_admin_token" "provider" {
  cluster_id = hcp_vault_cluster.hashistack.cluster_id
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    replace_triggered_by = [null_resource.recreate_trigger.id]
  }



}
