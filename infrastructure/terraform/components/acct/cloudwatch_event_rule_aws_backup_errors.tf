resource "aws_cloudwatch_event_rule" "aws_backup_errors" {
  name          = "${local.csi}-aws-backup-errors"
  description = "Forwards AWS Backup state changes to Custom Event Bus in Observability Account"

  event_pattern = jsonencode({
    source      = ["aws.backup"],
    "detail-type" = ["Backup Job State Change", "Restore Job State Change", "Copy Job State Change"],
    detail = {
      state = ["FAILED", "ABORTED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "aws_backup_errors" {
  rule     = aws_cloudwatch_event_rule.aws_backup_errors.name
  arn      = "arn:aws:events:eu-west-2:${var.observability_account_id}:event-bus/nhs-notify-main-acct-alerts-bus"
  role_arn = aws_iam_role.aws_backup_errors.arn
}

resource "aws_iam_role" "aws_backup_errors" {
  name = "${local.csi}-aws-backup-errors"

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

resource "aws_iam_policy" "aws_backup_errors" {
  name = "${local.csi}-aws-backup-errors"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "events:PutEvents",
      Resource = "arn:aws:events:eu-west-2:${var.observability_account_id}:event-bus/nhs-notify-main-acct-alerts-bus"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "aws_backup_errors" {
  role       = aws_iam_role.aws_backup_errors
  policy_arn = aws_iam_policy.aws_backup_errors
}
