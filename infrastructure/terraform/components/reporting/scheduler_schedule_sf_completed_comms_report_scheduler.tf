resource "aws_scheduler_schedule" "sf_completed_comms_report_scheduler" {
  name       = "${local.csi}-completed-comms-report-scheduler"
  description = "Schduler to trigger Step Function to generate the completed communications"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 1,8-18 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/London"

  target {
    arn      = aws_sfn_state_machine.completed_comms_report.arn
    role_arn = aws_iam_role.sf_completed_comms_report_scheduler.arn
  }
}

resource "aws_iam_role" "sf_completed_comms_report_scheduler" {
  name               = "${local.csi}-sf-completed-comms-rpt-scheduler-role"
  description        = "Role used by the State Machine Ingestion Scheduler"
  assume_role_policy = data.aws_iam_policy_document.completed_comms_report_scheduler_assumerole.json
}

data "aws_iam_policy_document" "completed_comms_report_scheduler_assumerole" {
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

resource "aws_iam_role_policy_attachment" "sf_completed_comms_report_scheduler" {
  role       = aws_iam_role.sf_completed_comms_report_scheduler.name
  policy_arn = aws_iam_policy.sf_completed_comms_report_scheduler.arn
}

resource "aws_iam_policy" "sf_completed_comms_report_scheduler" {
  name        = "${local.csi}-sfn-completed-comms-report-scheduler-policy"
  description = "Allow Scheduler to execute State Machine"
  path        = "/"
  policy      = data.aws_iam_policy_document.sf_completed_comms_report_scheduler.json
}

data "aws_iam_policy_document" "sf_completed_comms_report_scheduler" {
  statement {
    sid    = "AllowAthena"
    effect = "Allow"

    actions = [
      "states:StartExecution"
    ]

    resources = [
      aws_sfn_state_machine.completed_comms_report.arn
    ]
  }
}
