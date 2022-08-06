provider "aws" {
  assume_role {
    role_arn = var.provisioning_role_arn
    }  
    region = "us-east-1"
}


terraform {
  required_version = ">= 0.13"
  backend "s3" {}
}

data "aws_caller_identity" "current" {}

data "aws_region" "forwarding" {}


resource "aws_iam_role" "forwarding" {
  name = var.forwarding_role_name

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "events.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF

  tags = var.tags
}

data "aws_iam_policy_document" "event_forwarding" {
  statement {
    sid     = "ForwardEvents"
    actions = ["events:PutEvents"]
    resources = [
#      "arn:aws:events:${data.aws_region.current.name}:${var.target_account}:event-bus/${var.target_event_bus}"
       "arn:aws:events:us-east-1:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:us-east-2:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:us-west-1:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:us-west-2:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:ca-central-1:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:eu-central-1:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:eu-west-1:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:eu-west-2:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:eu-west-3:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:eu-north-1:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:ap-south-1:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:ap-southeast-1:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:ap-southeast-2:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:ap-northeast-1:${var.target_account}:event-bus/${var.target_event_bus}",
       "arn:aws:events:sa-east-1:${var.target_account}:event-bus/${var.target_event_bus}"
    ]
  }
}

resource "aws_iam_role_policy" "forwarding" {
  name   = "ForwardEvents"
  role   = aws_iam_role.forwarding.id
  policy = data.aws_iam_policy_document.event_forwarding.json
}

