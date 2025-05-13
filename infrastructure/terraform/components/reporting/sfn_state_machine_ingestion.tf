resource "aws_sfn_state_machine" "ingestion" {
  name     = "${local.csi}-state-machine-ingestion"
  role_arn = aws_iam_role.sfn_ingestion.arn

  definition = templatefile("${path.module}/templates/ingestion.json.tmpl", {
    query_ids_1 = [
      "${aws_athena_named_query.request_item_plan_status.id}",
      "${aws_athena_named_query.client_latest_name.id}"
    ]
    hash_query_ids_1 = [
      "${aws_athena_named_query.request_item_status.id}"
    ]
    query_ids_2 = [
      "${aws_athena_named_query.request_item_plan_completed_summary.id}",
      "${aws_athena_named_query.request_item_plan_completed_summary_batch.id}",
      "${aws_athena_named_query.request_item_status_summary.id}",
      "${aws_athena_named_query.request_item_status_summary_batch.id}"
    ]
    hash_query_ids_2 = []
    environment      = "${local.csi}"
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.reporting.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }
}

resource "aws_iam_role" "sfn_ingestion" {
  name               = "${local.csi}-sf-ingestion-role"
  description        = "Role used by the State Machine for Athena ingestion queries"
  assume_role_policy = data.aws_iam_policy_document.sfn_assumerole_ingestion.json
}

data "aws_iam_policy_document" "sfn_assumerole_ingestion" {
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

resource "aws_iam_role_policy_attachment" "sfn_ingestion" {
  role       = aws_iam_role.sfn_ingestion.name
  policy_arn = aws_iam_policy.sfn_ingestion.arn
}

resource "aws_iam_policy" "sfn_ingestion" {
  name        = "${local.csi}-sfn-ingestion-policy"
  description = "Allow Step Function State Machine to run Athena ingestion queries"
  path        = "/"
  policy      = data.aws_iam_policy_document.sfn_ingestion.json
}

#trivy:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "sfn_ingestion" {

  statement {
    sid    = "AllowSSM"
    effect = "Allow"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      aws_ssm_parameter.hash_key.arn
    ]
  }

  statement {
    sid    = "AllowAthena"
    effect = "Allow"

    actions = [
      "athena:startQueryExecution",
      "athena:stopQueryExecution",
      "athena:getQueryExecution",
      "athena:getDataCatalog",
      "athena:getNamedQuery"
    ]

    resources = [
      aws_athena_workgroup.ingestion.arn,
      "arn:aws:athena:${var.region}:${local.this_account}:datacatalog/*"
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
      "arn:aws:glue:${var.region}:${local.this_account}:catalog",
      aws_glue_catalog_database.reporting.arn,
      "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/*",
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
      aws_s3_bucket.data.arn,
      "${aws_s3_bucket.data.arn}/*",
      aws_s3_bucket.results.arn,
      "${aws_s3_bucket.results.arn}/*"
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
      "arn:aws:glue:${var.region}:${var.core_account_id}:catalog",
      "arn:aws:glue:${var.region}:${var.core_account_id}:database/comms-${var.core_env}-api-rpt-reporting",
      "arn:aws:glue:${var.region}:${var.core_account_id}:table/comms-${var.core_env}-api-rpt-reporting/transaction_history",
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
      "arn:aws:kms:${var.region}:${var.core_account_id}:key/*",
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
      "arn:aws:s3:::comms-${var.core_account_id}-${var.region}-${var.core_env}-api-rpt-reporting",
      "arn:aws:s3:::comms-${var.core_account_id}-${var.region}-${var.core_env}-api-rpt-reporting/kinesis-firehose-output/reporting/parquet/transactions/*"
    ]
  }

  statement {
    sid    = "AllowCloudwatchLogging"
    effect = "Allow"

    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*", # See https://docs.aws.amazon.com/step-functions/latest/dg/cw-logs.html & https://github.com/aws/aws-cdk/issues/7158
    ]
  }
}
