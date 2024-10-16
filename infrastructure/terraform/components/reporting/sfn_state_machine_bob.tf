resource "aws_sfn_state_machine" "bob" {
  name     = "${local.csi}-state-machine-bob"
  role_arn = aws_iam_role.sfn_bob.arn

  definition = templatefile("${path.module}/templates/bob.json.tmpl", {
    date_query_id = "${aws_athena_named_query.yesterday.id}"
    report_query_id = "${aws_athena_named_query.bob.id}"
    environment = "${local.csi}"
    output_root = "s3://${aws_s3_bucket.results.bucket}/core/"
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.reporting.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }
}

resource "aws_iam_role" "sfn_bob" {
  name               = "${local.csi}-sf-bob-role"
  description        = "Role used by the State Machine for Athena bob queries"
  assume_role_policy = data.aws_iam_policy_document.sfn_assumerole_bob.json
}

data "aws_iam_policy_document" "sfn_assumerole_bob" {
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

resource "aws_iam_role_policy_attachment" "sfn_bob" {
  role       = aws_iam_role.sfn_bob.name
  policy_arn = aws_iam_policy.sfn_bob.arn
}

resource "aws_iam_policy" "sfn_bob" {
  name        = "${local.csi}-sfn-bob-policy"
  description = "Allow Step Function State Machine to run Athena bob queries"
  path        = "/"
  policy      = data.aws_iam_policy_document.sfn_bob.json
}

data "aws_iam_policy_document" "sfn_bob" {

  statement {
    sid    = "AllowSSM"
    effect = "Allow"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      aws_ssm_parameter.bob_client_ids.arn
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
      "athena:getNamedQuery",
      "athena:GetQueryResults"
    ]

    resources = [
      aws_athena_workgroup.core.arn,
      aws_athena_workgroup.user.arn,
      "arn:aws:athena:eu-west-2:${local.this_account}:datacatalog/*"
    ]
  }

  statement {
    sid    = "AllowGlueCurrent"
    effect = "Allow"

    actions = [
      "glue:Get*"
    ]

    resources = [
      "arn:aws:glue:eu-west-2:${local.this_account}:catalog",
      aws_glue_catalog_database.reporting.arn,
      "arn:aws:glue:eu-west-2:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_status",
      "arn:aws:glue:eu-west-2:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_plan_status",
    ]
  }

  statement {
    sid    = "AllowS3ReadData"
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
    sid    = "AllowS3WriteResults"
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
}
