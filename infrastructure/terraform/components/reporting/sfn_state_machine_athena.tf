resource "aws_sfn_state_machine" "athena" {
  name     = "${local.csi}-state-machine-athena"
  role_arn = aws_iam_role.sfn_athena.arn

  definition = templatefile("${path.module}/files/state.tmpl.json", {
    ATHENA_WORKGROUP   = aws_athena_workgroup.reporting.name,
    S3_OUTPUT_LOCATION = "${aws_s3_bucket.reporting.bucket}/execution_results/nhs_notify_${var.environment}_item_status_iceberg",
    QUERY_STRING       = replace(aws_athena_named_query.reporting.query, "\"", "\\\"")
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.reporting.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }
}

resource "aws_iam_role" "sfn_athena" {
  name               = "${local.csi}-sf-athena-role"
  description        = "Role used by the State Machine for Athena"
  assume_role_policy = data.aws_iam_policy_document.sfn_assumerole.json
}

data "aws_iam_policy_document" "sfn_assumerole" {
  statement {
    sid    = "EcsAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "states.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "sfn_athena" {
  role       = aws_iam_role.sfn_athena.name
  policy_arn = aws_iam_policy.sfn_athena.arn
}

resource "aws_iam_policy" "sfn_athena" {
  name        = "${local.csi}-sfn-athena-policy"
  description = "Allow Step Function State Machine to run Athena queries"
  path        = "/"
  policy      = data.aws_iam_policy_document.sfn_athena.json
}

data "aws_iam_policy_document" "sfn_athena" {
  statement {
    sid    = "AllowAthena"
    effect = "Allow"

    actions = [
      "athena:startQueryExecution",
      "athena:stopQueryExecution",
      "athena:getQueryExecution",
      "athena:getDataCatalog"
    ]

    resources = [
      aws_athena_workgroup.reporting.arn,
      "arn:aws:athena:eu-west-2:${local.this_account}:datacatalog/*"
    ]
  }

  statement {
    sid    = "AllowGlueCurrent"
    effect = "Allow"

    actions = [
      "glue:Get*",
      "glue:UpdateTable"
    ]

    resources = [
      "arn:aws:glue:eu-west-2:${local.this_account}:catalog",
      aws_glue_catalog_database.reporting.arn,
      "arn:aws:glue:eu-west-2:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/nhs_notify_${var.environment}_item_status_iceberg",
    ]
  }

  statement {
    sid    = "AllowS3Current"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.reporting.arn,
      "${aws_s3_bucket.reporting.arn}/*"
    ]
  }

  statement {
    sid    = "AllowKMSCurrent"
    effect = "Allow"

    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:Decrypt"
    ]

    resources = [
      aws_kms_key.s3.arn
    ]
  }

  statement {
    sid    = "AllowGlueCore"
    effect = "Allow"

    actions = [
      "glue:Get*"
    ]

    resources = [
      "arn:aws:glue:eu-west-2:${var.core_account_id}:catalog",
      "arn:aws:glue:eu-west-2:${var.core_account_id}:database/comms-${var.core_env}-api-rpt-reporting",
      "arn:aws:glue:eu-west-2:${var.core_account_id}:table/comms-${var.core_env}-api-rpt-reporting/transaction_history",
    ]
  }

  statement {
    sid    = "AllowKMSCore"
    effect = "Allow"

    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:Decrypt"
    ]

    resources = [
      "arn:aws:kms:eu-west-2:${var.core_account_id}:key/*",
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "kms:ResourceAliases"
      values = [
        "alias/comms-${var.core_env}-api-s3"
      ]
    }
  }

  statement {
    sid    = "AllowS3Core"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::comms-${var.core_account_id}-eu-west-2-${var.core_env}-api-rpt-reporting",
      "arn:aws:s3:::comms-${var.core_account_id}-eu-west-2-${var.core_env}-api-rpt-reporting/kinesis-firehose-output/reporting/parquet/transactions/*"
    ]
  }

  statement {
    sid    = "AllowCloudwatchLogging1"
    effect = "Allow"

    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid    = "AllowCloudwatchLogging2"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.reporting.arn,
      "${aws_cloudwatch_log_group.reporting.arn}:*"
    ]
  }
}
