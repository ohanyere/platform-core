locals {
  oidc_provider_hostpath = replace(var.cluster_oidc_issuer_url, "https://", "")
  service_account_subjects = [
    for name in var.service_account_name_patterns : "system:serviceaccount:${var.namespace}:${name}"
  ]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type = "Federated"
      identifiers = [
        var.cluster_oidc_provider_arn,
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_hostpath}:aud"
      values = [
        "sts.amazonaws.com",
      ]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_provider_hostpath}:sub"
      values   = local.service_account_subjects
    }
  }
}

resource "aws_iam_role" "crossplane_provider" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "provider_permissions" {
  statement {
    sid = "S3Buckets"

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:GetBucket*",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetPublicAccessBlock",
      "s3:ListBucket",
      "s3:PutBucket*",
      "s3:PutBucketPolicy",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutPublicAccessBlock",
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::*",
    ]
  }

  statement {
    sid = "SQSQueues"

    actions = [
      "sqs:CreateQueue",
      "sqs:DeleteQueue",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags",
      "sqs:ListQueues",
      "sqs:SetQueueAttributes",
      "sqs:TagQueue",
      "sqs:UntagQueue",
    ]

    resources = [
      "arn:${var.aws_partition}:sqs:*:*:*",
    ]
  }

  statement {
    sid = "DynamoDBTables"

    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable",
      "dynamodb:DescribeTable",
      "dynamodb:ListTagsOfResource",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:UpdateTable",
    ]

    resources = [
      "arn:${var.aws_partition}:dynamodb:*:*:table/*",
    ]
  }

  statement {
    sid = "RDSInstances"

    actions = [
      "rds:AddTagsToResource",
      "rds:CreateDBInstance",
      "rds:DeleteDBInstance",
      "rds:Describe*",
      "rds:ListTagsForResource",
      "rds:ModifyDBInstance",
      "rds:RemoveTagsFromResource",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "ElastiCacheClusters"

    actions = [
      "elasticache:AddTagsToResource",
      "elasticache:CreateCacheCluster",
      "elasticache:DeleteCacheCluster",
      "elasticache:Describe*",
      "elasticache:ListTagsForResource",
      "elasticache:ModifyCacheCluster",
      "elasticache:RemoveTagsFromResource",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "NetworkDiscovery"

    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "crossplane_provider" {
  name   = "${var.role_name}-policy"
  policy = data.aws_iam_policy_document.provider_permissions.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "crossplane_provider" {
  role       = aws_iam_role.crossplane_provider.name
  policy_arn = aws_iam_policy.crossplane_provider.arn
}
