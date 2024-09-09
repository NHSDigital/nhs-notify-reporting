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

    resources = concat(
      local.core_glue_catalog_resources, # Access to all core account catalogs is required as they are all accessible via the default catalog in the environment's account
      [
        "arn:aws:glue:${var.region}:${var.aws_account_id}:catalog", # Local catalogs
        "arn:aws:glue:${var.region}:${var.aws_account_id}:database/${var.project}-*-reporting-database",
        "arn:aws:glue:${var.region}:${var.aws_account_id}:table/${var.project}-*-reporting-database/request_item_plan_completed_summary",
        "arn:aws:glue:${var.region}:${var.aws_account_id}:table/${var.project}-*-reporting-database/request_item_status"
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
      "arn:aws:kms:${var.region}:${var.aws_account_id}:alias/${var.project}-*-reporting-s3"
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
