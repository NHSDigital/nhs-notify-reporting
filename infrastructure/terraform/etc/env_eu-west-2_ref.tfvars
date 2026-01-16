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

batch_client_ids = [
  "perf-test-client-1",
  "perf-test-client-2"
]

email_filter_client_ids = [
  "perf-test-client-1",
  "perf-test-client-2"
]

enable_s3_backup = false

shared_infra_account_id  = "099709604300"
