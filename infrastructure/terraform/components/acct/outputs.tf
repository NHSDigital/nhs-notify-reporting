output "aws_account_id" {
  value = var.aws_account_id
}

output "log_subscription_role_arn" {
  value = module.obs_datasource.log_subscription_role_arn
}
