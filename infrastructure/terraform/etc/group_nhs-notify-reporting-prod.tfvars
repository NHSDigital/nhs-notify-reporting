group          = "nhs-notify-reporting-prod"
aws_account_id = "211125615884"

core_account_ids = [
  "746418818434"
]

# Allow Grafana cross account access
observability_account_id = "142549683766"

budget_amount          = 900
cost_anomaly_threshold = 20

bounded_contexts = [
  {
    name = "reporting"
    additional_policies = [
      "athena:*",
      "firehose:*",
      "glue:*",
      "kinesis:*"
    ]
  }
]

shared_infra_account_id  = "142549683766"
