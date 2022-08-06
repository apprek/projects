include {
  path = find_in_parent_folders()
}

terraform {
  source = "/Users/kapprey/code/cloud-custodian-policies/terraform/modules/event_iam_role"
}

inputs = {
  provisioning_role_arn = "arn:aws:iam::{remote_account_a}:role/infrastructure-terraform"

  tags = {
    Product      = "infrastructure"
    Environment  = "aws-testing"
    Type         = "cloud-custodian"
    HostStage    = "non-prod"
    Owner        = "cloud-infrastructure"
    OwnerContact = "cloud-infrastructure@corp_xyz.com"
    Company      = "corp_xyz"
  }
}
