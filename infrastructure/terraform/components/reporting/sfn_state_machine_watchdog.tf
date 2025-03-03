resource "aws_sfn_state_machine" "watchdog" {
  name     = "${local.csi}-state-machine-watchdog"
  role_arn = aws_iam_role.sfn_watchdog.arn

  definition = templatefile("${path.module}/templates/watchdog.json.tmpl", {
    watchdog_queries = [
      {
        metric_name = "OverdueRequestItemPlansCount",
        query_id    = aws_athena_named_query.overdue_request_item_plans.id
      },
      {
        metric_name = "OverdueRequestItemsCount",
        query_id    = aws_athena_named_query.overdue_request_items.id
      },
      {
        metric_name = "OverdueRequestsCount",
        query_id    = aws_athena_named_query.overdue_requests.id
      }
    ]
    environment = var.environment
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.reporting.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }
}

resource "aws_iam_role" "sfn_watchdog" {
  name               = "${local.csi}-sf-watchdog-role"
  description        = "Role used by the State Machine for Athena watchdog queries"
  assume_role_policy = data.aws_iam_policy_document.sfn_assumerole_watchdog.json
}

data "aws_iam_policy_document" "sfn_assumerole_watchdog" {
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

resource "aws_iam_role_policy_attachment" "sfn_watchdog" {
  role       = aws_iam_role.sfn_watchdog.name
  policy_arn = aws_iam_policy.sfn_watchdog.arn
}

resource "aws_iam_policy" "sfn_watchdog" {
  name        = "${local.csi}-sfn-watchdog-policy"
  description = "Allow Step Function State Machine to run Athena watchdog queries"
  path        = "/"
  policy      = data.aws_iam_policy_document.sfn_watchdog.json
}

data "aws_iam_policy_document" "sfn_watchdog" {

  statement {
    sid    = "AllowAthena"
    effect = "Allow"

    actions = [
      "athena:startQueryExecution",
      "athena:stopQueryExecution",
      "athena:getQueryExecution",
      "athena:getDataCatalog",
      "athena:getNamedQuery",
      "athena:GetQueryResults"
    ]

    resources = [
      aws_athena_workgroup.user.arn,
      "arn:aws:athena:${var.region}:${local.this_account}:datacatalog/*"
    ]
  }

  statement {
    sid    = "AllowGlueCurrent"
    effect = "Allow"

    actions = [
      "glue:Get*"
    ]

    resources = [
      "arn:aws:glue:${var.region}:${local.this_account}:catalog",
      aws_glue_catalog_database.reporting.arn,
      "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_status",
      "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_plan_status",
      "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_status_summary",
    ]
  }

  statement {
    sid    = "AllowS3CurrentReadData"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.data.arn,
      "${aws_s3_bucket.data.arn}/*"
    ]
  }

  statement {
    sid    = "AllowS3CurrentWriteResults"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
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
    sid    = "AllowCloudwatchMetrics"
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricData"
    ]

    resources = [
      "*"
    ]
  }
}
