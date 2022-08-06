# ./modules/remediation_role/main.tf

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

resource "aws_iam_role" "remediation" {
  name = var.remediation_role_name

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS": "arn:aws:iam::${var.operations_account}:root",
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF

  tags = var.tags
}

resource "aws_iam_role_policy" "manage_encryption" {
  name   = "ManageEncryption"
  role   = aws_iam_role.remediation.id
  policy = data.aws_iam_policy_document.manage_encryption.json
}

resource "aws_iam_role_policy" "terminate_noncompliant" {
  count  = var.allow_terminations ? 1 : 0
  name   = "TerminateNoncompliant"
  role   = aws_iam_role.remediation.id
  policy = data.aws_iam_policy_document.terminate_noncompliant.json
}

resource "aws_iam_role_policy_attachment" "security_hub" {
  role       = aws_iam_role.remediation.id
  policy_arn = "arn:aws:iam::aws:policy/AWSSecurityHubFullAccess"
}
