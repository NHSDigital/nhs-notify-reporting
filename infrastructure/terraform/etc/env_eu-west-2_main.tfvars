environment    = "main"
account_name   = "notify-reporting-dev"
aws_account_id = "381492132479"

parent_acct_environment = "main"

core_account_id = "257995483745"
core_env        = "internal-dev"

# PowerBI On-Premises Gateway variables:
enable_powerbi_gateway = true

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

private_subnet_cidrs = [
  "10.0.4.0/24",
  "10.0.5.0/24",
  "10.0.6.0/24"
]

instance_type    = "t3.medium"
root_volume_size = 30
desired_capacity = 1
min_size         = 1
max_size         = 1
enable_spot      = false
spot_max_price   = "0.3"

# Allow Grafana cross account access
shared_infra_account_id  = "099709604300"
oam_sink_id              = "66ebe791-9d3c-41cf-85a5-09765d71767f"

destination_backup_vault_arn = "arn:aws:backup:eu-west-2:390844765011:backup-vault:nhs-notify-reporting-dev-backup-vault"

is_primary_environent = true
