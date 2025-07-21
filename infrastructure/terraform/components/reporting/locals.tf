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
    ""
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
    ""
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

  # Check if each required SSM parameter exists individually
  recovery_key  = length(aws_ssm_parameter.powerbi_gateway_recovery_key) > 0 ? aws_ssm_parameter.powerbi_gateway_recovery_key[0].name : null
  client_secret = length(aws_ssm_parameter.powerbi_gateway_client_secret) > 0 ? aws_ssm_parameter.powerbi_gateway_client_secret[0].name : null
  client_id     = length(aws_ssm_parameter.powerbi_gateway_client_id) > 0 ? aws_ssm_parameter.powerbi_gateway_client_id[0].name : null
  tenant_id     = length(aws_ssm_parameter.powerbi_gateway_tenant_id) > 0 ? aws_ssm_parameter.powerbi_gateway_tenant_id[0].name : null

  # Create the powerbi_gateway_script only if var.enable_powerbi_gateway is true
  powerbi_gateway_script = var.enable_powerbi_gateway ? templatefile("${path.module}/templates/cloudinit_config.tmpl", {
    odbc_dsn_name       = "${local.csi}-dsn"
    odbc_description    = "AWS Simba Athena ODBC Connection for ${local.csi}"
    region              = var.region
    catalog             = "AWSDataCatalog"
    database            = aws_glue_catalog_database.reporting.name
    workgroup           = aws_athena_workgroup.user.name
    authentication_type = "Instance Profile"
    gateway_name        = "${local.csi}-gateway"
    recovery_key        = local.recovery_key
    client_secret       = local.client_secret
    client_id           = local.client_id
    tenant_id           = local.tenant_id
  }) : null

  use_core_glue_catalog_resources = length(var.core_account_ids) > 0 ? true : false

  core_glue_catalog_resources = local.use_core_glue_catalog_resources ? flatten([
    for account_id in var.core_account_ids : [
      "arn:aws:glue:${var.region}:${account_id}:catalog",
    ]
  ]) : []

  log_destination_arn = "arn:aws:logs:${var.region}:${var.observability_account_id}:destination:nhs-main-obs-firehose-logs"
}
