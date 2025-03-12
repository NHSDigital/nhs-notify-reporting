resource "aws_cloudwatch_event_rule" "alert_forwarding" {
  name        = "${local.csi}-forward-cloudwatch-alarms"
  description = "Forwards CloudWatch Alarm state changes to Custom Event Bus in Observability Account"

  event_pattern = jsonencode({
    "source"      = ["aws.cloudwatch"],
    "detail-type" = ["CloudWatch Alarm State Change"]
  })
}

resource "aws_cloudwatch_event_target" "alert_forwarding" {
  rule     = aws_cloudwatch_event_rule.alert_forwarding.name
  arn      = "arn:aws:events:eu-west-2:${var.observability_account_id}:event-bus/nhs-notify-main-acct-alerts-bus"
  role_arn = aws_iam_role.alert_forwarding.arn
}

resource "aws_iam_role" "alert_forwarding" {
  name = "${local.csi}-alert-forwarding"

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

resource "aws_iam_policy" "alert_forwarding" {
  name = "${local.csi}-alert-forwarding"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "events:PutEvents",
      Resource = "arn:aws:events:eu-west-2:${var.observability_account_id}:event-bus/nhs-notify-main-acct-alerts-bus"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "alert_forwarding" {
  role       = aws_iam_role.alert_forwarding.name
  policy_arn = aws_iam_policy.alert_forwarding.arn
}
