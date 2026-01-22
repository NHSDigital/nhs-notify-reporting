environment    = "main"
account_name   = "notify-reporting-dev"
aws_account_id = "381492132479"

parent_acct_environment = "main"

core_account_id = "257995483745"
core_env        = "internal-dev"

core_account_ids = [
  "257995483745", # dev
  "815490582396", # ref
  "736102632839"  # int & uat
]

# PowerBI On-Premises Gateway variables:
enable_powerbi_gateway = true
min_size               = 2
max_size               = 2
desired_capacity       = 2


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

shared_infra_account_id  = "099709604300"

destination_backup_vault_arn = "arn:aws:backup:eu-west-2:390844765011:backup-vault:nhs-notify-reporting-dev-backup-vault"
