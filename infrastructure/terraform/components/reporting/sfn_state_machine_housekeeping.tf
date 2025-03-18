resource "aws_sfn_state_machine" "housekeeping" {
  name     = "${local.csi}-state-machine-housekeeping"
  role_arn = aws_iam_role.sfn_housekeeping.arn

  definition = templatefile("${path.module}/templates/housekeeping.json.tmpl", {
    optimize_query_ids = [
      "${aws_athena_named_query.request_item_status_optimize.id}",
      "${aws_athena_named_query.request_item_plan_status_optimize.id}",
      "${aws_athena_named_query.request_item_plan_completed_summary_optimize.id}",
      "${aws_athena_named_query.request_item_plan_completed_summary_batch_optimize.id}",
      "${aws_athena_named_query.request_item_status_summary_optimize.id}",
      "${aws_athena_named_query.request_item_status_summary_batch_optimize.id}"
    ]
    vacuum_query_ids = [
      "${aws_athena_named_query.request_item_status_vacuum.id}",
      "${aws_athena_named_query.request_item_plan_status_vacuum.id}",
      "${aws_athena_named_query.request_item_plan_completed_summary_vacuum.id}",
      "${aws_athena_named_query.request_item_plan_completed_summary_batch_vacuum.id}",
      "${aws_athena_named_query.request_item_status_summary_vacuum.id}",
      "${aws_athena_named_query.request_item_status_summary_batch_vacuum.id}"
    ]
    database_name = "${aws_glue_catalog_database.reporting.name}"
    iam_role      = "${aws_iam_role.sfn_housekeeping.arn}"
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.reporting.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }
}

resource "aws_iam_role" "sfn_housekeeping" {
  name               = "${local.csi}-sf-housekeeping-role"
  description        = "Role used by the State Machine for Athena housekeeping queries"
  assume_role_policy = data.aws_iam_policy_document.sfn_assumerole_housekeeping.json
}

data "aws_iam_policy_document" "sfn_assumerole_housekeeping" {
  statement {
    sid    = "StateMachineAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "states.amazonaws.com",
        "glue.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "sfn_housekeeping" {
  role       = aws_iam_role.sfn_housekeeping.name
  policy_arn = aws_iam_policy.sfn_housekeeping.arn
}

resource "aws_iam_role_policy_attachment" "sfn_housekeeping_columnstats" {
  role       = aws_iam_role.sfn_housekeeping.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "sfn_housekeeping" {
  name        = "${local.csi}-sfn-housekeeping-policy"
  description = "Allow Step Function State Machine to run Athena housekeeping queries"
  path        = "/"
  policy      = data.aws_iam_policy_document.sfn_housekeeping.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "sfn_housekeeping" {

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
      aws_athena_workgroup.housekeeping.arn,
      "arn:aws:athena:${var.region}:${local.this_account}:datacatalog/*"
    ]
  }

  statement {
    sid    = "AllowGlueCurrent"
    effect = "Allow"

    actions = [
      "glue:Get*",
      "glue:UpdateTable",
      "glue:StartColumnStatisticsTaskRun"
    ]

    resources = [
      "arn:aws:glue:${var.region}:${local.this_account}:catalog",
      aws_glue_catalog_database.reporting.arn,
      "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/*"
    ]
  }

  statement {
    sid    = "AllowS3Current"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject"
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

  statement {
    sid    = "AllowPassRole"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      aws_iam_role.sfn_housekeeping.arn
    ]
  }
}
