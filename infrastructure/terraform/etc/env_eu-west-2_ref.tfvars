environment    = "ref"
account_name   = "notify-reporting-dev"
aws_account_id = "381492132479"

parent_acct_environment = "main"

core_account_id = "815490582396"
core_env        = "ref"

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

batch_client_ids = [
  "perf-test-client-1",
  "perf-test-client-2"
]

enable_s3_backup = false

# Allow Grafana cross account access
observability_account_id = "273354664196"
oam_sink_id              = "e04b741a-9ba8-43e2-865d-3a76519b675e"
