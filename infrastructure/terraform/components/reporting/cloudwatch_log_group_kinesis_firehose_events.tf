resource "aws_cloudwatch_log_group" "kinesis_firehose_events" {
  name              = "/aws/kinesisfirehose/${local.csi}-events"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_stream" "kinesis_firehose_events_extended_s3" {
  name           = "${local.csi}-events-extended-s3"
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_events.name
}
