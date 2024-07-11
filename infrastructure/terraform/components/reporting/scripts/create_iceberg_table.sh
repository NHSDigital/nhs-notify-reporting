#!/bin/bash

# Creates Iceberg table for reporting if it doesn't exist already

ENV=${1:-"no_env"}

if [[ ${ENV} == "no_env" ]]; then
    echo "Environment name not provided as first argument"
    exit 1
fi

table_exists=$(aws glue get-tables --database-name nhs-notify-${ENV}-reporting-database | jq 'any(.TableList[].Name == "'nhs_notify_${ENV}_item_status_iceberg'"; .)')

if [[ ${table_exists} == "true" ]]; then
    echo "Table already exists for this environment in the database, hence exiting gracefully"
    exit 0
fi


account_id=""

if [[ ${ENV} == "prod" ]]; then
    account_id="211125615884"
else
    account_id="381492132479"
fi

execution_id=$( aws athena start-query-execution \
  --query-string "CREATE TABLE IF NOT EXISTS nhs_notify_${ENV}_item_status_iceberg (
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
  );" \
  --work-group nhs-notify-${ENV}-reporting \
  --query-execution-context Database=nhs-notify-${ENV}-reporting-database \
  --result-configuration OutputLocation="s3://nhs-notify-${account_id}-eu-west-2-${ENV}-daily-report/execution_results/nhs_notify_${ENV}_item_status_iceberg/" | jq -r '.QueryExecutionId')

echo "Execution ID is: ${execution_id}"

status=$(aws athena get-query-execution --query-execution-id $execution_id | jq -r '.QueryExecution.Status.State')

if [[ $? == 0 ]] && [[ $status != "FAILED" ]]; then
    echo "Table 'nhs_notify_${ENV}_item_status_iceberg' created!!"
else
    echo "Table creation failed"
    exit 1
fi
