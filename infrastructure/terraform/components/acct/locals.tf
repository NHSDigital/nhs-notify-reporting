locals {
  use_core_glue_catalog_resources = length(var.core_account_ids) > 0 ? true : false

  core_glue_catalog_resources = local.use_core_glue_catalog_resources ? flatten([
    for account_id in var.core_account_ids : [
      "arn:aws:glue:${var.region}:${account_id}:catalog",
    ]
  ]) : []
}
