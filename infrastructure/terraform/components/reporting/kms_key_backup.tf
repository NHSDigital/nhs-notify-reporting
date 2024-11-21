resource "aws_kms_key" "backup" {
  count = var.enable_s3_backup ? 1 : 0


  description             = "CMK for encrypting backup vault"
  deletion_window_in_days = local.parameter_bundle.default_kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.backup[0].json
}

resource "aws_kms_alias" "backup" {
  count = var.enable_s3_backup ? 1 : 0

  name          = "alias/${local.csi}-backup"
  target_key_id = aws_kms_key.backup[0].key_id
}


data "aws_iam_policy_document" "backup" {
  count = var.enable_s3_backup ? 1 : 0

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
        local.parameter_bundle.iam_resource_arns.any_authorised_user_in_this_account
      ]
    }
  }
}
