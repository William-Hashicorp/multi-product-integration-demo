terraform {
  required_providers {
    tfe = {
      version = "~> 0.49.0"
    }
  }
# backend "remote" {
#     hostname     = "app.terraform.io"
#     organization = "William-Hashicorp"

#     workspaces {
#       name = "0_control-workspace"
#     }
#   }

}

provider "tfe" {}

resource "tfe_workspace" "networking" {
  name          = "1_networking"
  organization  = var.tfc_organization
  project_id    = var.tfc_project_id
  terraform_version = var.terraform_version_value

  vcs_repo {
    identifier = var.repo_identifier
    oauth_token_id = var.oauth_token_id
    branch = var.repo_branch
  }

  working_directory = "1_networking"
  queue_all_runs = false
  assessments_enabled = false
  global_remote_state = true
}

resource "tfe_workspace" "hcp_clusters" {
  name          = "2_hcp-clusters"
  organization  = var.tfc_organization
  project_id    = var.tfc_project_id
  terraform_version = var.terraform_version_value

  vcs_repo {
    identifier = var.repo_identifier
    oauth_token_id = var.oauth_token_id
    branch = var.repo_branch
  }

  working_directory = "2_hcp-clusters"
  queue_all_runs = false
  assessments_enabled = false
  global_remote_state = true
}

resource "tfe_workspace" "vault_auth_config" {
  name          = "3_vault-auth-config"
  organization  = var.tfc_organization
  project_id    = var.tfc_project_id
  terraform_version = var.terraform_version_value

  vcs_repo {
    identifier = var.repo_identifier
    oauth_token_id = var.oauth_token_id
    branch = var.repo_branch
  }

  working_directory = "3_vault-auth-config"
  queue_all_runs = false
  assessments_enabled = false
  global_remote_state = true
}

resource "tfe_workspace" "boundary_config" {
  name          = "4_boundary-config"
  organization  = var.tfc_organization
  project_id    = var.tfc_project_id
  terraform_version = var.terraform_version_value

  vcs_repo {
    identifier = var.repo_identifier
    oauth_token_id = var.oauth_token_id
    branch = var.repo_branch
  }

  working_directory = "4_boundary-config"
  queue_all_runs = false
  assessments_enabled = false
  global_remote_state = true
}

resource "tfe_workspace" "nomad_cluster" {
  name          = "5_nomad-cluster"
  organization  = var.tfc_organization
  project_id    = var.tfc_project_id
  terraform_version = var.terraform_version_value

  vcs_repo {
    identifier = var.repo_identifier
    oauth_token_id = var.oauth_token_id
    branch = var.repo_branch
  }

  working_directory = "5_nomad-cluster"
  queue_all_runs = false
  assessments_enabled = false
  global_remote_state = true
}

resource "tfe_workspace" "nomad_nodes" {
  name          = "6_nomad-nodes"
  organization  = var.tfc_organization
  project_id    = var.tfc_project_id
  terraform_version = var.terraform_version_value

  vcs_repo {
    identifier = var.repo_identifier
    oauth_token_id = var.oauth_token_id
    branch = var.repo_branch
  }

  working_directory = "6_nomad-nodes"
  queue_all_runs = false
  assessments_enabled = false
  global_remote_state = true
}

resource "tfe_workspace" "nomad_workload" {
  name          = "7_workload"
  organization  = var.tfc_organization
  project_id    = var.tfc_project_id
  terraform_version = var.terraform_version_value

  vcs_repo {
    identifier = var.repo_identifier
    oauth_token_id = var.oauth_token_id
    branch = var.repo_branch
  }

  working_directory = "7_workload"
  queue_all_runs = false
  assessments_enabled = false
  global_remote_state = true
}

resource "tfe_workspace" "boundary-adv" {
  name          = "8_boundary-adv"
  organization  = var.tfc_organization
  project_id    = var.tfc_project_id
  terraform_version = var.terraform_version_value

  vcs_repo {
    identifier = var.repo_identifier
    oauth_token_id = var.oauth_token_id
    branch = var.repo_branch
  }

  working_directory = "8_boundary-adv"
  queue_all_runs = false
  assessments_enabled = false
  global_remote_state = true
}



resource "tfe_workspace_run" "networking" {
  workspace_id    = tfe_workspace.networking.id

  apply {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 1
    retry_backoff_min = 5
  }
  destroy {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 1
    retry_backoff_min = 5
  }
}

resource "tfe_workspace_run" "hcp_clusters" {
  depends_on = [ tfe_workspace_run.networking ]
  workspace_id    = tfe_workspace.hcp_clusters.id

  apply {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 1
    retry_backoff_min = 5
  }
  destroy {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 1
    retry_backoff_min = 5
  }
}

resource "tfe_workspace_run" "vault_auth_config" {
  depends_on = [ tfe_workspace_run.hcp_clusters ]
  workspace_id    = tfe_workspace.vault_auth_config.id

  apply {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 1
    retry_backoff_min = 5
  }
  destroy {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 1
    retry_backoff_min = 5
  }
}

resource "tfe_workspace_run" "boundary_config" {
  depends_on = [ tfe_workspace_run.vault_auth_config ]
  workspace_id    = tfe_workspace.boundary_config.id

  apply {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 1
    retry_backoff_min = 5
  }
  destroy {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 1
    retry_backoff_min = 5
  }
}

resource "tfe_workspace_run" "nomad_cluster" {
  depends_on = [ tfe_workspace_run.boundary_config ]
  workspace_id    = tfe_workspace.nomad_cluster.id

  apply {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 5
    retry_backoff_min = 5
  }
  destroy {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 5
    retry_backoff_min = 5
  }
}

resource "tfe_workspace_run" "nomad_nodes" {
  depends_on = [ tfe_workspace_run.nomad_cluster ]
  workspace_id    = tfe_workspace.nomad_nodes.id

  apply {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 5
    retry_backoff_min = 5
  }
  destroy {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 5
    retry_backoff_min = 5
  }
}

resource "tfe_workspace_run" "nomad_workload" {
  depends_on = [ tfe_workspace_run.nomad_nodes ]
  workspace_id    = tfe_workspace.nomad_workload.id

  apply {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 5
    retry_backoff_min = 5
  }
  destroy {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 5
    retry_backoff_min = 5
  }
}

resource "tfe_workspace_run" "boundary-adv" {
  depends_on = [ tfe_workspace_run.nomad_workload ]
  workspace_id    = tfe_workspace.boundary-adv.id

  apply {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 5
    retry_backoff_min = 5
  }
  destroy {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 5
    retry_backoff_min = 5
  }
}
