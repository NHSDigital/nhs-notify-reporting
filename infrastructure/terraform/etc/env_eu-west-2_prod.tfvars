environment    = "prod"
account_name   = "notify-reporting-prod"
aws_account_id = "211125615884"

core_account_id = "746418818434"
core_env        = "prod"

core_account_ids = [
  "746418818434"
]

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

batch_client_ids = [
  "c10ab104-86ae-48dc-b243-4906760952d3",
  "688040bc-92ea-4037-89f4-d105c9ae59a4"
]

enable_vault_lock_configuration = true

shared_infra_account_id  = "142549683766"

destination_backup_vault_arn = "arn:aws:backup:eu-west-2:369399915558:backup-vault:nhs-notify-reporting-prod-backup-vault"
