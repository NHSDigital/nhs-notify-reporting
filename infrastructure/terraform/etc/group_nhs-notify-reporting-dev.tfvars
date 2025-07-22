group          = "nhs-notify-reporting-dev"
aws_account_id = "381492132479"

enable_powerbi_gateway = false

core_account_ids = [
  "257995483745", # dev
  "815490582396", # ref
  "736102632839"  # int & uat
]

# Allow Grafana cross account access
observability_account_id = "099709604300"

budget_amount          = 500
cost_anomaly_threshold = 20
