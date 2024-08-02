resource "aws_kms_key" "ebs" {
  count = var.enable_powerbi_gateway ? 1 : 0

  description             = "CMK for encrypting EBS volumes"
  deletion_window_in_days = local.parameter_bundle.default_kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.ebs[0].json
}

resource "aws_kms_alias" "ebs" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name          = "alias/${local.csi}-ebs"
  target_key_id = aws_kms_key.ebs[0].key_id
}


data "aws_iam_policy_document" "ebs" {
  count = var.enable_powerbi_gateway ? 1 : 0

  statement {
    sid    = "AllowLocalIAMAdministration"
    effect = "Allow"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:TagResource"
    ]

    resources = [
      "*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        local.parameter_bundle.iam_resource_arns.any_authorised_user_in_this_account,

      ]
    }
  }

  statement {
    sid    = "AllowUsageAccess"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        local.parameter_bundle.iam_resource_arns.any_authorised_user_in_this_account,
        "arn:aws:iam::${local.this_account}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"

      ]
    }
  }
  statement {
    sid    = "AllowAutoscalingToUse"
    effect = "Allow"

    actions = [
      "kms:CreateGrant",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.this_account}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
      ]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}
