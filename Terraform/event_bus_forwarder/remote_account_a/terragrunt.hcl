include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../" #modules/event_bus_forwarder"
}

inputs = {
  provisioning_role_arn = "arn:aws:iam::{remote_account_a}:role/infrastructure-terraform"

  tags = {
    Product      = "infrastructure"
    Environment  = "aws-testing"
    Type         = "cloud-custodian"
    HostStage    = "non-prod"
    Owner        = "cloud-infrastructure"
    OwnerContact = "cloud-infrastructure@comp_xyz.com"
    Company      = "comp_xyz"
  }
}
