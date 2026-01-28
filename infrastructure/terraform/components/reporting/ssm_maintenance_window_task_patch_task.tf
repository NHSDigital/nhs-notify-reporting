resource "aws_ssm_maintenance_window_task" "patch_task_sunday" {
  count = var.enable_powerbi_gateway ? 1 : 0

  description = "Windows Server 2022 Sunday Patch Task"
  window_id   = aws_ssm_maintenance_window.patch_window_sunday[0].id
  task_arn    = "AWS-RunPatchBaseline"
  task_type   = "RUN_COMMAND"

  targets {
    key = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.windows_instances_sunday[0].id]
  }

  task_invocation_parameters {
    run_command_parameters {
      comment = "Patching Sunday instances"
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      parameter {
        name   = "RebootOption"
        values = ["RebootIfNeeded"]
      }
    }
  }

  priority        = 1
  max_concurrency = "1"
  max_errors      = "1"
}

resource "aws_ssm_maintenance_window_task" "patch_task_wednesday" {
  count = var.enable_powerbi_gateway && var.powerbi_gateway_instance_count >= 2 ? 1 : 0

  description = "Windows Server 2022 Wednesday Patch Task"
  window_id   = aws_ssm_maintenance_window.patch_window_wednesday[0].id
  task_arn    = "AWS-RunPatchBaseline"
  task_type   = "RUN_COMMAND"

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.windows_instances_wednesday[0].id]
  }

  task_invocation_parameters {
    run_command_parameters {
      comment = "Patching Wednesday instance"
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      parameter {
        name   = "RebootOption"
        values = ["RebootIfNeeded"]
      }
    }
  }

  priority        = 1
  max_concurrency = "1"
  max_errors      = "1"
}

## Remove me later - replaced by above two tasks
resource "aws_ssm_maintenance_window_task" "patch_task" {
  count = var.enable_powerbi_gateway ? 1 : 0

  description = "Windows Server 2022 Patch Task"
  window_id   = aws_ssm_maintenance_window.patch_window[0].id
  task_arn    = "AWS-RunPatchBaseline"
  task_type   = "RUN_COMMAND"

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.windows_instances[0].id]
  }

  task_invocation_parameters {
    run_command_parameters {
      comment = "Patching Windows Instances"
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
    }
  }

  priority        = 1
  max_concurrency = "2"
  max_errors      = "1"
}
