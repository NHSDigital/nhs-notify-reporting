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

  name               = "${local.csi}-powerbi-gateway"
  description        = "PowerBI Gateway Instance Permissions"
  path               = "/"
  policy             = data.aws_iam_policy_document.powerbi_gateway_permissions_policy[0].json
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
      "arn:aws:logs:${local.parameter_bundle.region}:${local.this_account}:log-group:*",
    ]
  }

  statement {
    sid    = "AllowS3ReportingBucket"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.reporting.arn,
      "${aws_s3_bucket.reporting.arn}/*" # Question here: should we have another per env bucket for writing reports back?
    ]
  }

  statement {
    sid    = "AllowAthenaAccess1"
    effect = "Allow"

    actions = [
        "athena:GetQueryResults",
        "athena:GetQueryExecution",
        "athena:StartQueryExecution",
        "athena:GetWorkGroup"
    ]

    resources = [
      aws_athena_workgroup.user.arn
    ]
  }

  statement {
    sid    = "AllowAthenaAccess2"
    effect = "Allow"

    actions = [
        "athena:ListDatabases",
        "athena:GetDatabases",
        "athena:ListTableMetadata",
        "athena:GetTableMetadata"

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
        "athena:GetTables",
        "athena:GetTable",
    ]

    resources = [ "*" ] # https://docs.aws.amazon.com/athena/latest/APIReference/API_ListDataCatalogs.html

    # condition {
    #   test     = "StringLike"
    #   variable = "aws:RequestTag/Environment"
    #   values   = [ var.environment ]
    # }

    # condition {
    #   test     = "StringLike"
    #   variable = "aws:RequestTag/Component"
    #   values   = [ var.component ]
    # }

    # condition {
    #   test     = "StringLike"
    #   variable = "aws:RequestTag/Project"
    #   values   = [ var.project ]
    # }
  }

  statement {
    sid    = "AllowGlueAccess"
    effect = "Allow"

    actions = [
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetDatabases"
    ]

    resources = [
      "arn:aws:glue:${var.region}:${local.this_account}:catalog",
      "arn:aws:glue:${var.region}:${local.this_account}:table/${aws_glue_catalog_database.reporting.name}/completed_request_item_plan_summary",
      aws_glue_catalog_database.reporting.arn
    ]
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
}
