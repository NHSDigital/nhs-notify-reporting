resource "aws_scheduler_schedule" "sf_ingestion_scheduler" {
  name       = "${local.csi}-ingestion-scheduler"
  description = "Schduler to trigger Step Function to run ingestion queries"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 1,4,8-18 ? * * *)"
  schedule_expression_timezone = "Europe/London"

  target {
    arn      = aws_sfn_state_machine.ingestion.arn
    role_arn = aws_iam_role.sf_ingestion_scheduler.arn
  }
}

resource "aws_iam_role" "sf_ingestion_scheduler" {
  name               = "${local.csi}-sf-ingestion-scheduler-role"
  description        = "Role used by the State Machine Ingestion Scheduler"
  assume_role_policy = data.aws_iam_policy_document.ingestion_scheduler_assumerole.json
}

data "aws_iam_policy_document" "ingestion_scheduler_assumerole" {
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

resource "aws_iam_role_policy_attachment" "sf_ingestion_scheduler" {
  role       = aws_iam_role.sf_ingestion_scheduler.name
  policy_arn = aws_iam_policy.sf_ingestion_scheduler.arn
}

resource "aws_iam_policy" "sf_ingestion_scheduler" {
  name        = "${local.csi}-sfn-ingestion-scheduler-policy"
  description = "Allow Scheduler to execute State Machine"
  path        = "/"
  policy      = data.aws_iam_policy_document.sf_ingestion_scheduler.json
}

data "aws_iam_policy_document" "sf_ingestion_scheduler" {
  statement {
    sid    = "AllowAthena"
    effect = "Allow"

    actions = [
      "states:StartExecution"
    ]

    resources = [
      aws_sfn_state_machine.ingestion.arn
    ]
  }
}
