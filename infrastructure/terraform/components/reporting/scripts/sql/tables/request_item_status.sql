CREATE TABLE IF NOT EXISTS ${table_name} (
    clientid string,
    campaignid string,
    sendinggroupid string,
    requestitemid string,
    requestrefid string,
    requestid string,
    nhsnumberhash string,
    createdtime time,
    completedtime time,
    completedcommunicationtypes array<string>,
    failedcommunicationtypes array<string>,
    delivered boolean,
    failed boolean,
    failedreason string
)
PARTITIONED BY (bucket(32, clientid), month(createdtime), month(completedtime))
LOCATION '${s3_location}'
TBLPROPERTIES (
  'table_type'='ICEBERG',
  'format'='PARQUET',
  'write_compression'='ZSTD'
);
