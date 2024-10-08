CREATE TABLE IF NOT EXISTS ${table_name} (
    clientid string,
    campaignid string,
    sendinggroupid string,
    sendinggroupidversion string,
    requestrefid string,
    requestid string,
    communicationtype string,
    supplier string,
    createddate date,
    completeddate date,
    status string,
    failedreason string,
    contactdetailsource string,
    channeltype string,
    requestitemcount int
)
PARTITIONED BY (month(createddate), month(completeddate))
LOCATION '${s3_location}'
TBLPROPERTIES (
  'table_type'='ICEBERG',
  'format'='PARQUET',
  'write_compression'='ZSTD'
);
