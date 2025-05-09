environment  = "uat"
account_name = "notify-reporting-dev"

core_account_id = "736102632839"
core_env        = "uat"

# PowerBI On-Premises Gateway variables:
enable_powerbi_gateway = false

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

enable_s3_backup = false

# Allow Grafana cross account access
observability_account_id = "273354664196"
