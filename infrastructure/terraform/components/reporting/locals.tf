locals {

  # Compound Scope Identifier
  csi = replace(
    format(
      "%s-%s-%s",
      var.project,
      var.environment,
      var.component,
    ),
    "_",
    "",
  )

  # CSI for use in resources with a global namespace, i.e. S3 Buckets
  csi_global = replace(
    format(
      "%s-%s-%s-%s",
      local.base_parameter_bundle.project,
      local.this_account,
      local.base_parameter_bundle.region,
      local.base_parameter_bundle.environment
    ),
    "_",
    "",
  )

  base_parameter_bundle = {
    project                             = var.project
    environment                         = var.environment
    component                           = var.component
    group                               = var.group
    region                              = var.region
    account_ids                         = var.account_ids
    account_name                        = var.account_name
    default_kms_deletion_window_in_days = var.default_kms_deletion_window_in_days
    default_tags                        = local.deployment_default_tags
    pipeline_overrides                  = jsondecode(var.pipeline_overrides)
    terraform_root_dir                  = var.terraform_root_dir
  }

  parameter_bundle = merge(
    local.base_parameter_bundle, {
      iam_resource_arns = local.iam_resource_arns,
    }
  )

  deployment_default_tags = {
    AccountId   = var.account_ids[var.account_name]
    AccountName = var.account_name
    Project     = var.project
    Environment = var.environment
    Component   = var.component
    Group       = var.group
    Module      = var.module
  }

  this_account = local.base_parameter_bundle.account_ids[local.base_parameter_bundle.account_name]
}
