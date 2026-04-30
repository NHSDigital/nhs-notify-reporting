resource "aws_glue_catalog_table" "event_staging" {
  name          = "event_staging"
  description   = "Staging table for all event records."
  database_name = aws_glue_catalog_database.reporting.name

  table_type = "EXTERNAL_TABLE"

  storage_descriptor {
    location = "s3://${aws_s3_bucket.events.bucket}/${local.firehose_output_path_events}"

    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    # additional columns must be added at the end of the list
    columns {
      name = "specversion"
      type = "string"
    }
    columns {
      name = "id"
      type = "string"
    }
    columns {
      name = "source"
      type = "string"
    }
    columns {
      name = "subject"
      type = "string"
    }
    columns {
      name = "type"
      type = "string"
    }
    columns {
      name = "time"
      type = "string"
    }
    columns {
      name = "datacontenttype"
      type = "string"
    }
    columns {
      name = "dataschema"
      type = "string"
    }
    columns {
      name = "data"
      type = "string"
    }
    columns {
      name = "traceparent"
      type = "string"
    }
    columns {
      name = "tracestate"
      type = "string"
    }
    columns {
      name = "partitionkey"
      type = "string"
    }
    columns {
      name = "recordedtime"
      type = "string"
    }
    columns {
      name = "sampledrate"
      type = "string"
    }
    columns {
      name = "sampledrate"
      type = "int"
    }
    columns {
      name = "sequence"
      type = "string"
    }
    columns {
      name = "severitytext"
      type = "string"
    }
    columns {
      name = "severitynumber"
      type = "int"
    }
    columns {
      name = "dataclassification"
      type = "string"
    }
    columns {
      name = "dataregulation"
      type = "string"
    }
    columns {
      name = "datacategory"
      type = "string"
    }
  }

  partition_keys {
    name = "type"
    type = "string"
  }

  partition_keys {
    name = "year"
    type = "int"
  }
  partition_keys {
    name = "month"
    type = "int"
  }
  partition_keys {
    name = "day"
    type = "int"
  }

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
    compressionType       = "none"
    classification        = "parquet"
  }
}

resource "aws_glue_partition_index" "event_record" {
  database_name = aws_glue_catalog_database.reporting.name
  table_name    = aws_glue_catalog_table.event_staging.name

  partition_index {
    index_name = "data"
    keys       = ["type", "year", "month", "day"]
  }

  timeouts {
    create = "60m"
    delete = "60m"
  }
}
