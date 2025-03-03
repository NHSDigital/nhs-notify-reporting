resource "aws_iam_instance_profile" "powerbi_gateway" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name = "${local.csi}-powerbi-gateway"
  role = aws_iam_role.powerbi_gateway_role[0].name
}

data "aws_iam_policy_document" "powerbi_gateway_assume_role_policy" {
  count = var.enable_powerbi_gateway ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "powerbi_gateway_role" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name               = "${local.csi}-powerbi-gateway"
  description        = "PowerBI Gateway Instance Role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.powerbi_gateway_assume_role_policy[0].json
}


resource "aws_iam_policy" "powerbi_gateway_permissions_policy" {
  count = var.enable_powerbi_gateway ? 1 : 0

  name        = "${local.csi}-powerbi-gateway"
  description = "PowerBI Gateway Instance Permissions"
  path        = "/"
  policy      = data.aws_iam_policy_document.powerbi_gateway_permissions_policy[0].json
}

resource "aws_iam_role_policy_attachment" "powerbi_gateway_permissions_policy_attachment" {
  count = var.enable_powerbi_gateway ? 1 : 0

  role       = aws_iam_role.powerbi_gateway_role[0].name
  policy_arn = aws_iam_policy.powerbi_gateway_permissions_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "powerbi_gateway_ssm_policy_attachment" {
  count = var.enable_powerbi_gateway ? 1 : 0

  role       = aws_iam_role.powerbi_gateway_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "powerbi_gateway_permissions_policy" {
  count = var.enable_powerbi_gateway ? 1 : 0

  statement {
    sid    = "AllowLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${local.parameter_bundle.region}:${local.this_account}:log-group:*",
    ]
  }

  statement {
    sid    = "AllowS3DataBucket"
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
    sid    = "AllowS3ResultsBucket"
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
    sid    = "AllowAthenaAccess1"
    effect = "Allow"

    actions = [
      "athena:GetQueryResults",
      "athena:GetQueryResultsStream",
      "athena:GetQueryExecution",
      "athena:StartQueryExecution",
      "athena:GetWorkGroup",
      "athena:GetNamedQuery"
    ]

    resources = [
      aws_athena_workgroup.user.arn
    ]
  }

  statement {
    sid    = "AllowAthenaAccess2"
    effect = "Allow"

    actions = [
      "athena:GetDatabase",
      "athena:GetTableMetadata",
      "athena:GetDataCatalog",
      "athena:GetTable"
    ]

    resources = [
      "arn:aws:athena:${var.region}:${local.this_account}:datacatalog/AWSDataCatalog"
    ]
  }

  statement {
    sid    = "AllowAthenaAccess3"
    effect = "Allow"

    actions = [
      "athena:ListDataCatalogs",
      "athena:ListDatabases",
      "athena:ListTableMetadata",
      "athena:ListWorkGroups"
    ]

    resources = ["*"] # Access to List all above is required. Condition keys not supported for these resources.
  }

  statement {
    sid    = "AllowGlueAccess"
    effect = "Allow"

    actions = [
      "glue:GetTable",
      "glue:GetTables",
      "glue:BatchGetTable",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetPartition",
      "glue:GetPartitions"
    ]

    resources = concat(
      local.core_glue_catalog_resources, # Access to all core account catalogs is required as they are all accessible via the default catalog in the environment's account
      [
        aws_glue_catalog_database.reporting.arn,
        "arn:aws:glue:${var.region}:${var.core_account_id}:catalog",
        "arn:aws:glue:${var.region}:${local.this_account}:catalog",
        # Tables
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_plan_completed_summary",
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_plan_completed_summary_batch",
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_plan_status",
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_status",
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_status_summary",
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_status_summary_batch",
        # Views
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_plan_completed_summary_all",
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_status_summary_all",
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/dates",
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/letters_invoice_units",
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/latency_percentiles",
      ]
    )
  }

  statement {
    sid    = "AllowS3KMSAccess"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.s3.arn
    ]
  }

  statement {
    sid    = "AllowSSMAccess"
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParameterHistory",
    ]

    resources = [
      aws_ssm_parameter.powerbi_gateway_recovery_key[0].arn,
      aws_ssm_parameter.powerbi_gateway_client_id[0].arn,
      aws_ssm_parameter.powerbi_gateway_client_secret[0].arn,
      aws_ssm_parameter.powerbi_gateway_tenant_id[0].arn
    ]
  }
}
