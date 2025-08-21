locals {
  terraform_state_bucket = format(
    "%s-tfscaffold-%s-%s",
    var.project,
    var.aws_account_id,
    var.region,
  )

  # Central account component deployed with "nhs" project name, not "nhs-notify" for legacy reasons.
  terraform_state_bucket_acct = format(
    "%s-tfscaffold-%s-%s",
    "nhs",
    var.aws_account_id,
    var.region,
  )

  default_tags = merge(
    var.default_tags,
    {
      Project     = var.project
      Environment = var.environment
      Component   = var.component
      Group       = var.group
      Name        = local.csi
    },
  )
}
