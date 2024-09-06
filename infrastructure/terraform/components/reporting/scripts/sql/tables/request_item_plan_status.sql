CREATE TABLE IF NOT EXISTS ${table_name} (
    clientid string,
    campaignid string,
    sendinggroupid string,
    sendinggroupidversion string,
    requestitemrefid string,
    requestitemid string,
    requestrefid string,
    requestid string,
    requestitemplanid string,
    communicationtype string,
    supplier string,
    createdtime timestamp,
    completedtime timestamp,
    status string,
    failedreason string,
    contactdetailsource string,
    channeltype string,
    timestamp bigint
)
PARTITIONED BY (bucket(32, clientid), month(createdtime), month(completedtime))
LOCATION '${s3_location}'
TBLPROPERTIES (
  'table_type'='ICEBERG',
  'format'='PARQUET',
  'write_compression'='ZSTD'
);
