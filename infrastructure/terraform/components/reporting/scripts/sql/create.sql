CREATE TABLE IF NOT EXISTS nhs_notify_${ENV}_item_status_iceberg (
    clientid string,
    campaignid string,
    sendinggroupid string,
    requestitemid string,
    requestrefid string,
    requestid string,
    nhsnumberhash string,
    createddate date,
    completeddate date,
    nhsapp_success boolean,
    email_success boolean,
    sms_success boolean,
    letter_success boolean,
    nhsapp_failed boolean,
    email_failed boolean,
    sms_failed boolean,
    letter_failed boolean,
    enriched boolean,
    sending boolean,
    delivered boolean,
    failed boolean)
  PARTITIONED BY (clientid, month(createddate), month(completeddate))
  LOCATION 's3://nhs-notify-${account_id}-eu-west-2-${ENV}-daily-report/powerbi/nhs_notify_${ENV}_item_status_iceberg'
  TBLPROPERTIES (
    'table_type'='ICEBERG',
    'format'='PARQUET',
    'write_compression'='ZSTD'
  );