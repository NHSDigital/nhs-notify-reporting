data "aws_iam_policy_document" "sso_read_only_table_access" {
  count = var.enable_powerbi_gateway ? 1 : 0

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

    resources = [
        aws_glue_catalog_database.reporting.arn,
        "arn:aws:glue:${var.region}:${var.core_account_id}:catalog",
        "arn:aws:glue:${var.region}:${local.this_account}:catalog",
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_plan_completed_summary",
        "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/request_item_status",
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

    resources = [ "*" ] # Access to List all above is required. Condition keys not supported for these resources.
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
}
