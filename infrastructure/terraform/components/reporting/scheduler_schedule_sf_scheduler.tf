resource "aws_scheduler_schedule" "sf_scheduler" {
  name       = "${local.csi}-scheduler"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 9-22 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/London"

  target {
    arn      = aws_sfn_state_machine.athena.arn
    role_arn = aws_iam_role.sf_scheduler.arn
  }
}

resource "aws_iam_role" "sf_scheduler" {
  name               = "${local.csi}-sf-scheduler-role"
  description        = "Role used by the State Machine Scheduler"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assumerole.json
}

data "aws_iam_policy_document" "scheduler_assumerole" {
  statement {
    sid    = "EcsAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "scheduler.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "sf_scheduler" {
  role       = aws_iam_role.sf_scheduler.name
  policy_arn = aws_iam_policy.sf_scheduler.arn
}

resource "aws_iam_policy" "sf_scheduler" {
  name        = "${local.csi}-sfn-scheduler-policy"
  description = "Allow Scheduler to execute State Machine every hour"
  path        = "/"
  policy      = data.aws_iam_policy_document.sf_scheduler.json
}

data "aws_iam_policy_document" "sf_scheduler" {
  statement {
    sid    = "AllowAthena"
    effect = "Allow"

    actions = [
      "states:StartExecution"
    ]

    resources = [
      aws_sfn_state_machine.athena.arn
    ]
  }
}
