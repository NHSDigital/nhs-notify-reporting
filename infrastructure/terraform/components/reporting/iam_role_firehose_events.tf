resource "aws_iam_role" "firehose_events" {
  name               = "${local.csi}-firehose-events-role"
  description        = "Role used by Firehose to deliver eventsub events into reporting S3"
  assume_role_policy = data.aws_iam_policy_document.firehose_events_assume_role.json
}

data "aws_iam_policy_document" "firehose_events_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "firehose_events" {
  role       = aws_iam_role.firehose_events.name
  policy_arn = aws_iam_policy.firehose_events.arn
}

resource "aws_iam_policy" "firehose_events" {
  name        = "${local.csi}-firehose-events-policy"
  description = "Permissions for Firehose delivery from eventsub SNS to reporting S3"
  policy      = data.aws_iam_policy_document.firehose_events.json
}

data "aws_iam_policy_document" "firehose_events" {
  statement {
    sid    = "AllowS3BucketMeta"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]

    resources = [
      aws_s3_bucket.data.arn,
    ]
  }

  statement {
    sid    = "AllowS3ObjectWrite"
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.data.arn}/${local.firehose_output_path_prefix}/*",
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogging"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.kinesis_firehose_events.arn,
      aws_cloudwatch_log_stream.kinesis_firehose_events_extended_s3.arn,
    ]
  }

  statement {
    sid    = "AllowGlueSchemaAccess"
    effect = "Allow"

    actions = [
      "glue:GetTable",
      "glue:GetTableVersion",
      "glue:GetTableVersions"
    ]

    resources = [
      "arn:aws:glue:${var.region}:${var.aws_account_id}:catalog"
    ]
  }

  statement {
    sid    = "AllowKMSEncryption"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]

    resources = [
      aws_kms_key.s3.arn,
    ]
  }
}
