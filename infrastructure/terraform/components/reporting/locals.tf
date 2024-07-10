locals {
    deployment_default_tags = {
    AccountId   = var.account_ids[var.account_name]
    AccountName = var.account_name
    Project     = var.project
    Environment = var.environment
    Component   = var.component
    Group       = var.group
    Module      = var.module
  }
}
