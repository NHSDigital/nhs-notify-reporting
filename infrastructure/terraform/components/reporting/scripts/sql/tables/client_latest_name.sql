CREATE TABLE IF NOT EXISTS ${table_name} (
    clientid string,
    clientname string,
    timestamp bigint
)
LOCATION '${s3_location}'
TBLPROPERTIES (
  'table_type'='ICEBERG',
  'format'='PARQUET',
  'write_compression'='ZSTD'
);
