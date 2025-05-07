resource "aws_cloudwatch_metric_alarm" "stuck_request_items" {
  alarm_name          = "${local.csi}-stuck-request-items"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  alarm_description   = "Request items stuck in an ENRICHED or PENDING_ENRICHMENT state for longer than an expected time window"
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "max_stuck_request_items_count"
    expression  = "SELECT MAX(StuckRequestItemsCount) FROM \"Notify/Watchdog\" WHERE environment='${var.environment}'"
    return_data = "true"
    period      = 3600
  }
}
