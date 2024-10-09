data "aws_iam_policy_document" "sso_read_only_table_access" {

  statement {
    sid    = "AllowGlueAccess"
    effect = "Allow"

    actions = [
      "glue:BatchGetTable",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:GetTable",
      "glue:GetTables"
    ]
    # Access to all core account catalogs is required as they are all accessible via the default catalog in the environment's account
    # Database and Table level access is restricted to just the desired tables. This does NOT allow blanket access to all catalogs/databases/tables.
    # This is a PowerBI Desktop requirement/limitation, not AWS or Athena ODBC Driver.
    resources = concat(
      local.core_glue_catalog_resources,
      [
        "arn:aws:glue:${var.region}:${var.aws_account_id}:catalog", # Local catalogs
        "arn:aws:glue:${var.region}:${var.aws_account_id}:database/${var.project}-*-reporting-database",
        # Tables
        "arn:aws:glue:${var.region}:${var.aws_account_id}:table/${var.project}-*-reporting-database/request_item_plan_completed_summary",
        "arn:aws:glue:${var.region}:${var.aws_account_id}:table/${var.project}-*-reporting-database/request_item_plan_completed_summary_batch",
        "arn:aws:glue:${var.region}:${var.aws_account_id}:table/${var.project}-*-reporting-database/request_item_plan_status",
        "arn:aws:glue:${var.region}:${var.aws_account_id}:table/${var.project}-*-reporting-database/request_item_status",
        "arn:aws:glue:${var.region}:${var.aws_account_id}:table/${var.project}-*-reporting-database/request_item_status_summary",
        "arn:aws:glue:${var.region}:${var.aws_account_id}:table/${var.project}-*-reporting-database/request_item_status_summary_batch",
        # Views
        "arn:aws:glue:${var.region}:${var.aws_account_id}:table/${var.project}-*-reporting-database/request_item_plan_completed_summary_all",
        "arn:aws:glue:${var.region}:${var.aws_account_id}:table/${var.project}-*-reporting-database/request_item_status_summary_all",
      ],
    )
  }

  statement {
    sid    = "AllowAthenaAccess1"
    effect = "Allow"

    actions = [
      "athena:GetNamedQuery",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetQueryResultsStream",
      "athena:GetWorkGroup",
      "athena:StartQueryExecution"
    ]

    resources = [
      "arn:aws:athena:${var.region}:${var.aws_account_id}:workgroup/${var.project}-*-reporting-user"
    ]
  }

  statement {
    sid    = "AllowAthenaAccess2"
    effect = "Allow"

    actions = [
      "athena:GetDataCatalog",
      "athena:GetDatabase",
      "athena:GetTable",
      "athena:GetTableMetadata"
    ]

    resources = [
      "arn:aws:athena:${var.region}:${var.aws_account_id}:datacatalog/AWSDataCatalog"
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
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext"
    ]

    resources = [
      "arn:aws:kms:${var.region}:${var.aws_account_id}:*"
    ]

    condition {
      test = "ForAnyValue:StringLike"
      variable = "kms:ResourceAliases"
      values = [
        "alias/${var.project}-*-reporting-s3"
      ]
    }
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
      "arn:aws:s3:::${var.project}-${var.aws_account_id}-${var.region}-*-data",
      "arn:aws:s3:::${var.project}-${var.aws_account_id}-${var.region}-*-data/*"
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
      "arn:aws:s3:::${var.project}-${var.aws_account_id}-${var.region}-*-results",
      "arn:aws:s3:::${var.project}-${var.aws_account_id}-${var.region}-*-results/*"
    ]
  }
}
