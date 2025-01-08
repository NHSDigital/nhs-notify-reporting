CREATE TABLE IF NOT EXISTS ${table_name} (
    clientid string,
    campaignid string,
    sendinggroupid string,
    sendinggroupidversion string,
    sendinggroupname string,
    sendinggroupcreatedtime timestamp,
    requestitemrefid string,
    requestitemid string,
    requestrefid string,
    requestid string,
    nhsnumberhash string,
    createdtime timestamp,
    completedtime timestamp,
    completedcommunicationtypes array<string>,
    failedcommunicationtypes array<string>,
    status string,
    failedreason string,
    patientodscode string,
    timestamp bigint
)
PARTITIONED BY (bucket(32, clientid), month(createdtime), month(completedtime))
LOCATION '${s3_location}'
TBLPROPERTIES (
  'table_type'='ICEBERG',
  'format'='PARQUET',
  'write_compression'='ZSTD'
);
