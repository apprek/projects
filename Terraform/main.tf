# ~/code/cloud-custodian-policies/terraform/main.tf


module "event_bus_forwarder-us-east-1" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.us-east-1"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}

module "event_bus_forwarder-us-east-2" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.us-east-2"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}


module "event_bus_forwarder-us-west-1" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.us-west-1"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}


module "event_bus_forwarder-us-west-2" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.us-west-2"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}


module "event_bus_forwarder-eu-central-1" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.eu-central-1"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}


module "event_bus_forwarder-eu-west-1" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.eu-west-1"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}

module "event_bus_forwarder-eu-west-2" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.eu-west-2"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}

module "event_bus_forwarder-eu-west-3" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.eu-west-3"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}

module "event_bus_forwarder-eu-north-1" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.eu-north-1"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}

module "event_bus_forwarder-ap-south-1" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.ap-south-1"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}

module "event_bus_forwarder-ap-southeast-1" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.ap-southeast-1"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}

module "event_bus_forwarder-ap-southeast-2" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.ap-southeast-2"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}

module "event_bus_forwarder-ap-northeast-1" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.ap-northeast-1"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}

module "event_bus_forwarder-ap-northeast-2" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.ap-northeast-2"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}


module "event_bus_forwarder-ca-central-1" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.ca-central-1"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role
}

module "event_bus_forwarder-sa-east-1" {
  source = "~/code/cloud-custodian-policies/terraform/modules/event_bus_forwarder"
  providers = {
    aws = "aws.sa-east-1"
  }
  tags = var.tags
  provisioning_role_arn = var.provisioning_role_arn
  aws_iam_role = var.aws_iam_role 
}


