resource "aws_kinesis_firehose_delivery_stream" "events" {
  name        = "${local.csi}-events"
  destination = "extended_s3"

  server_side_encryption {
    enabled  = true
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn  = aws_kms_key.s3.arn
  }

  extended_s3_configuration {
    role_arn    = aws_iam_role.firehose_events.arn
    bucket_arn  = aws_s3_bucket.events.arn
    kms_key_arn = aws_kms_key.s3.arn

    buffering_interval = 300
    buffering_size     = 128

    prefix              = "${local.firehose_output_path_events}/!{partitionKeyFromQuery:type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "${local.firehose_output_path_prefix}/firehose-errors/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

    dynamic_partitioning_configuration {
      enabled = true
    }

    processing_configuration {
      enabled = true

      processors {
        type = "MetadataExtraction"

        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }

        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{type:.type}"
        }
      }
    }

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.kinesis_firehose_events.name
      log_stream_name = aws_cloudwatch_log_stream.kinesis_firehose_events_extended_s3.name
    }
  }
}
