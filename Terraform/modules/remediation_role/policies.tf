data "aws_ebs_default_kms_key" "current" {}

// Apparently data.aws_ebs_default_kms_key.current.key_arn
// can return either a true ARN or an alias. If it returns
// the alias, using that value in an IAM policy will error out.
// Take this extra step in the name of reliability.
data "aws_kms_key" "ebs_key" {
  key_id = data.aws_ebs_default_kms_key.current.key_arn
}

data "aws_iam_policy_document" "terminate_noncompliant" {
  statement {
    sid = "TerminateResources"
    actions = [
      "ec2:TerminateInstances",
      "elasticfilesystem:DeleteFileSystem",
      "elasticfilesystem:DeleteFileSystemPolicy",
      "elasticfilesystem:DeleteMountTarget",
      "rds:DeleteDBInstance",
      "redshift:DeleteCluster",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "elasticmapreduce:DeleteSecurityConfiguration",
      "es:DeleteElasticsearchDomain",
      "dynamodb:DeleteTable"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "manage_encryption" {
  statement {
    sid = "ManageSnapshots"
    actions = [
      "ec2:AttachVolume",
      "ec2:CopySnapshot",
      "ec2:CreateSnapshot",
      "ec2:CreateVolume",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DescribeSnapshots",
      "ec2:DetachVolume",
      "ec2:ModifySnapshotAttribute",
      "ec2:ResetSnapshotAttribute",
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ManageTags"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeTags",
      "elasticfilesystem:CreateTags",
      "elasticfilesystem:DeleteTags",
      "elasticfilesystem:DescribeTags",
      "elasticfilesystem:ListTagsForResource",
      "elasticfilesystem:TagResource",
      "elasticfilesystem:UntagResource",
      "kinesis:AddTagsToStream",
      "kinesis:ListTagsForStream",
      "kinesis:RemoveTagsFromStream",
      "kms:ListResourceTags",
      "kms:TagResource",
      "kms:UntagResource",
      "rds:AddTagsToResource",
      "rds:ListTagsForResource",
      "rds:RemoveTagsFromResource",
      "redshift:CreateTags",
      "redshift:DeleteTags",
      "redshift:DescribeTags",
      "resource-explorer:*",
      "sqs:ListQueueTags",
      "sqs:TagQueue",
      "sqs:UntagQueue",
      "tag:GetResources",
      "tag:UntagResources",
      "tag:GetTagValues",
      "tag:GetTagKeys",
      "tag:TagResources",
    ]
    resources = ["*"]
  }

  statement {
    sid = "PublishLocalLogsAndMetrics"
    actions = [
      "cloudwatch:PutMetricData",
      "iam:ListAccountAliases",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "sqs:ListQueues",
    ]
    resources = ["*"]
  }

  statement {
    sid = "WriteCentralizedLogs"
    actions = [
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:SendMessage",
      "sqs:SendMessageBatch",
    ]
    resources = [
      "arn:aws:s3:::operations-indigo/cloud-custodian",
      "arn:aws:s3:::operations-indigo/cloud-custodian/*",
      "arn:aws:sqs:*:767904627276:CloudCustodian-Mailer",
    ]
  }

  statement {
    sid = "ReadAccess"
    actions = [
      "ec2:Describe*",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DescribeSecurityGroups",
      "elasticfilesystem:DescribeFileSystemPolicy",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "kinesis:DescribeStream",
      "kinesis:ListStreams",
      "kms:DescribeKey",
      "kms:ListAliases",
      "kms:ListKeys",
      "rds:Describe*",
      "redshift:DescribeClusters",
      "s3:GetBucket*",
      "s3:GetEncryptionConfiguration",
      "s3:HeadBucket",
      "s3:ListAllMyBuckets",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "dynamodb:GetItem",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:BatchGetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:ConditionCheckItem"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ConfigureDefaultEBSEncryption"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncryptFrom",
    ]
    resources = [data.aws_kms_key.ebs_key.arn]
  }

  statement {
    sid = "ManageResourceEncryption"
    actions = [
      "ec2:ModifyInstanceAttribute",
      "kinesis:StartStreamEncryption",
      "redshift:ModifyCluster",
      "s3:PutEncryptionConfiguration",
      "sqs:SetQueueAttributes",
    ]
    resources = ["*"]
  }
}
