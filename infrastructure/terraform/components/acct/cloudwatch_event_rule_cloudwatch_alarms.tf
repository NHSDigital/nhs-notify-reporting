resource "aws_cloudwatch_event_rule" "cloudwatch_alarms" {
  name        = "${local.csi}-cloudwatch-alarm-fowarding"
  description = "Forwards CloudWatch Alarm state changes to Custom Event Bus in Observability Account"

  event_pattern = jsonencode({
    "source"      = ["aws.cloudwatch"],
    "detail-type" = ["CloudWatch Alarm State Change"]
  })
}

resource "aws_cloudwatch_event_target" "cloudwatch_alarms" {
  rule     = aws_cloudwatch_event_rule.cloudwatch_alarms.name
  arn      = "arn:aws:events:eu-west-2:${var.observability_account_id}:event-bus/nhs-notify-main-acct-alerts-bus"
  role_arn = aws_iam_role.cloudwatch_alarms.arn
}

resource "aws_iam_role" "cloudwatch_alarms" {
  name = "${local.csi}-cloudwatch-alarms"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "events.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "cloudwatch_alarms" {
  name = "${local.csi}-cloudwatch-alarms"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "events:PutEvents",
      Resource = "arn:aws:events:eu-west-2:${var.observability_account_id}:event-bus/nhs-notify-main-acct-alerts-bus"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_alarms" {
  role       = aws_iam_role.cloudwatch_alarms.name
  policy_arn = aws_iam_policy.cloudwatch_alarms.arn
}
