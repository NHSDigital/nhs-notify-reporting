resource "aws_scheduler_schedule" "sf_housekeeping_scheduler" {
  name       = "${local.csi}-housekeeping-scheduler"
  description = "Schduler to trigger Step Function to run housekeeping queries"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 2 ? * SUN *)"
  schedule_expression_timezone = "Europe/London"

  target {
    arn      = aws_sfn_state_machine.housekeeping.arn
    role_arn = aws_iam_role.sf_housekeeping_scheduler.arn
  }
}

resource "aws_iam_role" "sf_housekeeping_scheduler" {
  name               = "${local.csi}-sf-housekeeping-scheduler-role"
  description        = "Role used by the State Machine Housekeeping Scheduler"
  assume_role_policy = data.aws_iam_policy_document.housekeeping_scheduler_assumerole.json
}

data "aws_iam_policy_document" "housekeeping_scheduler_assumerole" {
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

resource "aws_iam_role_policy_attachment" "sf_housekeeping_scheduler" {
  role       = aws_iam_role.sf_housekeeping_scheduler.name
  policy_arn = aws_iam_policy.sf_housekeeping_scheduler.arn
}

resource "aws_iam_policy" "sf_housekeeping_scheduler" {
  name        = "${local.csi}-sfn-housekeeping-scheduler-policy"
  description = "Allow Scheduler to execute State Machine"
  path        = "/"
  policy      = data.aws_iam_policy_document.sf_housekeeping_scheduler.json
}

data "aws_iam_policy_document" "sf_housekeeping_scheduler" {
  statement {
    sid    = "AllowAthena"
    effect = "Allow"

    actions = [
      "states:StartExecution"
    ]

    resources = [
      aws_sfn_state_machine.housekeeping.arn
    ]
  }
}
