# <WY>  AWs provider
provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "tfc_organization" {
  type    = string
  default = ""
}

# <WY> add 7_workload to give permission to run 7_workload workspace.

variable "tfc_workspace_names" {
  type    = set(string)
  default = ["1_networking", "5_nomad-cluster", "4_boundary-config", "6_nomad-nodes","7_workload"]
}

resource "aws_iam_role" "doormat_role" {
  for_each = var.tfc_workspace_names
  name = "tfc-doormat-role_${each.key}"
  tags = {
    hc-service-uri = "app.terraform.io/${var.tfc_organization}/${each.key}"
  }
  max_session_duration = 43200
  assume_role_policy   = data.aws_iam_policy_document.doormat_assume.json
  inline_policy {
    name   = "doormat_permissions"
    policy = data.aws_iam_policy_document.doormat_policy.json
  }
}

data "aws_iam_policy_document" "doormat_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity",
      "sts:TagSession"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::397512762488:user/doormatServiceUser"] # infrasec_prod   
    }
  }
}

# The following is just for completeness of the sample
data "aws_iam_policy_document" "doormat_policy" {
  statement {
    actions   = ["*"]
    resources = ["*"]
  }
}

# <WY> Output the aws_account_id with ARNs
output "doormat_role_arns" {
  value = { for key, role in aws_iam_role.doormat_role : key => role.arn }
  description = "The ARNs of the doormat IAM roles created for each workspace."
}

