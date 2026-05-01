resource "aws_sns_topic" "events" {
  name              = "${local.csi}-events-topic"
  kms_master_key_id = aws_kms_key.s3.arn
}

resource "aws_sns_topic_policy" "events" {
  arn    = aws_sns_topic.events.arn
  policy = data.aws_iam_policy_document.sns_topic_events.json
}

data "aws_iam_policy_document" "sns_topic_events" {
  policy_id = "__default_policy_ID"

  statement {
    sid    = "AllowAllSNSActionsFromSharedAccount"
    effect = "Allow"
    actions = [
      "SNS:Publish",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.shared_infra_account_id}:root"
      ]
    }

    resources = [
      aws_sns_topic.events.arn,
    ]
  }
}

resource "aws_sns_topic_subscription" "events_firehose" {
  topic_arn             = aws_sns_topic.events.arn
  protocol              = "firehose"
  subscription_role_arn = aws_iam_role.sns_events_firehose.arn
  endpoint              = aws_kinesis_firehose_delivery_stream.events.arn
  raw_message_delivery  = true
}
