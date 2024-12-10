resource "aws_scheduler_schedule" "sf_watchdog_scheduler" {
  name       = "${local.csi}-watchdog-scheduler"
  description = "Schduler to trigger Step Function to run watchdog queries"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(30 1 ? * * *)"
  schedule_expression_timezone = "Europe/London"

  target {
    arn      = aws_sfn_state_machine.watchdog.arn
    role_arn = aws_iam_role.sf_watchdog_scheduler.arn
  }
}

resource "aws_iam_role" "sf_watchdog_scheduler" {
  name               = "${local.csi}-sf-watchdog-scheduler-role"
  description        = "Role used by the State Machine Housekeeping Scheduler"
  assume_role_policy = data.aws_iam_policy_document.watchdog_scheduler_assumerole.json
}

data "aws_iam_policy_document" "watchdog_scheduler_assumerole" {
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

resource "aws_iam_role_policy_attachment" "sf_watchdog_scheduler" {
  role       = aws_iam_role.sf_watchdog_scheduler.name
  policy_arn = aws_iam_policy.sf_watchdog_scheduler.arn
}

resource "aws_iam_policy" "sf_watchdog_scheduler" {
  name        = "${local.csi}-sfn-watchdog-scheduler-policy"
  description = "Allow Scheduler to execute State Machine"
  path        = "/"
  policy      = data.aws_iam_policy_document.sf_watchdog_scheduler.json
}

data "aws_iam_policy_document" "sf_watchdog_scheduler" {
  statement {
    sid    = "AllowAthena"
    effect = "Allow"

    actions = [
      "states:StartExecution"
    ]

    resources = [
      aws_sfn_state_machine.watchdog.arn
    ]
  }
}
