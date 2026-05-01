resource "aws_iam_role" "sns_events_firehose" {
  name               = "${local.csi}-sns-events-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.sns_events_firehose_assume_role.json
}

data "aws_iam_policy_document" "sns_events_firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "sns_events_firehose_delivery" {
  name        = "${local.csi}-sns-events-firehose-delivery"
  description = "Allows SNS to publish events to the events Firehose stream"
  policy      = data.aws_iam_policy_document.sns_events_firehose_delivery.json
}

data "aws_iam_policy_document" "sns_events_firehose_delivery" {
  statement {
    sid    = "AllowFirehoseDelivery"
    effect = "Allow"

    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]

    resources = [
      aws_kinesis_firehose_delivery_stream.events.arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "sns_events_firehose_delivery" {
  role       = aws_iam_role.sns_events_firehose.name
  policy_arn = aws_iam_policy.sns_events_firehose_delivery.arn
}
