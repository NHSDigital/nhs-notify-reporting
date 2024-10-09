CREATE TABLE IF NOT EXISTS ${table_name} (
    clientid string,
    campaignid string,
    sendinggroupid string,
    sendinggroupidversion string,
    requestrefid string,
    requestid string,
    createddate date,
    requestedcount int,
    deliveredcount int,
    failedcount int,
    completedcount int,
    outstandingcount int,
    nhsappdeliveredcount int,
    emaildeliveredcount int,
    smsdeliveredcount int,
    letterdeliveredcount int,
    nhsappfailedcount int,
    emailfailedcount int,
    smsfailedcount int,
    letterfailedcount int
)
PARTITIONED BY (month(createddate))
LOCATION '${s3_location}'
TBLPROPERTIES (
  'table_type'='ICEBERG',
  'format'='PARQUET',
  'write_compression'='ZSTD'
);
