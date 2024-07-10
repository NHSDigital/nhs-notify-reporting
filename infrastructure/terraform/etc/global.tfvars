project                   = "nhs-notify"
aws_account_id            = "1234567890"
superuser_role_name       = "NOTIFYDeployRole"
app_deployer_role_name    = "NOTIFYDeployRole"
cloudtrail_log_group_name = "NHSDAudit_trail_log_group"

account_ids = {
  nhs-notify-reporting-dev  = "381492132479"
  nhs-notify-reporting-prod = "211125615884"
}
