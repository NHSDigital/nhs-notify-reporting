module "kms" {
  source = "git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/kms?ref=v1.0.8"

  aws_account_id = var.aws_account_id
  component      = var.component
  environment    = var.environment
  project        = var.project
  region         = var.region

  name            = "main"
  deletion_window = var.kms_deletion_window
  alias           = "alias/${local.csi}"
  iam_delegation  = true
}
