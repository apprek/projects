# ./terraform/modules/event_bus_forwarder/main.tf

provider "aws" {
  
}

terraform {
  required_version = ">= 0.13"
  backend "s3" {}
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_role" "forwarding" {
  name = "CloudCustodian-EventForwarder"
}


resource "aws_cloudwatch_event_rule" "custodian_forwarder" {
  name        = var.rule_name
  description = "Forward CloudTrail events for processing by Cloud Custodian"

  event_pattern = <<EOF
{
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "ec2.amazonaws.com",
      "elasticfilesystem.amazonaws.com",
      "kinesis.amazonaws.com",
      "rds.amazonaws.com",
      "redshift.amazonaws.com",
      "s3.amazonaws.com",
      "sqs.amazonaws.com",
      "elasticmapreduce.amazonaws.com",
      "es.amazonaws.com",
      "dynamodb.amazonaws.com"
    ],
    "eventName": [
      "CreateBucket",
      "CreateCluster",
      "CreateDBInstance",
      "CreateFileSystem",
      "CreateQueue",
      "CreateStream",
      "RunInstances",
      "AuthorizeSecurityGroupIngress",
      "RunJobFlow",
      "CreateSecurityConfiguration",
      "CreateElasticsearchDomain",
      "CreateTable"
    ],
    "errorCode": [
      {
        "exists": false
      }
    ]
  }
}
EOF

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "operations_event_bus" {
  rule      = aws_cloudwatch_event_rule.custodian_forwarder.name
  target_id = "OperationsEventBus"
  arn       = "arn:aws:events:${data.aws_region.current.name}:${var.target_account}:event-bus/${var.target_event_bus}"
  role_arn  = data.aws_iam_role.forwarding.arn
}





