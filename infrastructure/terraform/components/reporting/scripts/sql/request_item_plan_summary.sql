CREATE TABLE IF NOT EXISTS ${table_name} (
    clientid string,
    campaignid string,
    sendinggroupid string,
    communicationtype string,
    supplier string,
    createddate date,
    completeddate date,
    status string,
    failedreason string,
    requestitemcount int
)
PARTITIONED BY (month(createddate), month(completeddate))
LOCATION '${s3_url}/data/${table_name}'
TBLPROPERTIES (
  'table_type'='ICEBERG',
  'format'='PARQUET',
  'write_compression'='ZSTD'
);
