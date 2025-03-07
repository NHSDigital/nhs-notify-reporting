resource "aws_cloudwatch_event_rule" "alert_forwarding" {
  name        = "${local.csi}-forward-cloudwatch-alarms"
  description = "Forwards CloudWatch Alarm state changes to Account B"

  event_pattern = jsonencode({
    "source"      = ["aws.cloudwatch"],
    "detail-type" = ["CloudWatch Alarm State Change"]
  })
}

# Target: Send events to Account B's custom event bus
resource "aws_cloudwatch_event_target" "alert_forwarding" {
  rule     = aws_cloudwatch_event_rule.alert_forwarding.name
  arn      = "arn:aws:events:eu-west-2:273354664196:event-bus/nhs-notify-main-obs-alerts-bus"
  role_arn = aws_iam_role.alert_forwarding.arn
}

# IAM Role: Allow EventBridge to send events to Account B
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

# IAM Policy: Allow publishing events to Account B's event bus
resource "aws_iam_policy" "alert_forwarding" {
  name = "${local.csi}-alert-forwarding"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "events:PutEvents",
      Resource = "arn:aws:events:eu-west-2:273354664196:event-bus/nhs-notify-main-obs-alerts-bus"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "alert_forwarding" {
  role       = aws_iam_role.alert_forwarding.name
  policy_arn = aws_iam_policy.alert_forwarding.arn
}
