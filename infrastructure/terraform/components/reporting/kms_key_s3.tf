resource "aws_kms_key" "s3" {
  description             = "CMK for encrypting S3 buckets in the account"
  deletion_window_in_days = local.parameter_bundle.default_kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.s3.json
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${local.csi}-s3"
  target_key_id = aws_kms_key.s3.key_id
}


data "aws_iam_policy_document" "s3" {
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
      "kms:GenerateDataKey"
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
    sid    = "AllowCIAccess"
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
      ]
    }
  }
}
