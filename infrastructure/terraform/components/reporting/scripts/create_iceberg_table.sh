#!/usr/bin/env bash

# Creates Iceberg table for reporting if it doesn't exist already

ENV=${1:-"no_env"}
account_id=${2:-"no_account"}

if [[ ${ENV} == "no_env" ]] || [[ ${account_id} == "no_account" ]] ; then
    echo "Environment name or Account ID not provided as first argument"
    exit 1
fi

glue_database="nhs-notify-${ENV}-reporting-database"
glue_table_name="nhs_notify_${ENV}_item_status_iceberg"

table_exists=$(aws glue get-tables --database-name ${glue_database} | jq 'any(.TableList[].Name == "'${glue_table_name}'"; .)')

if [[ ${table_exists} == "true" ]]; then
    echo "Table already exists for this environment in the database, hence exiting gracefully"
    exit 0
fi

ls -al

sql_file="./components/reporting/scripts/sql/create.sql"
sql_file_updated="./components/reporting/scripts/sql/create_updated.sql"

#Substituting placeholders with actual values and piping to a new sql file to be used as query string
sed "s/\${ENV}/${ENV}/g; s/\${account_id}/${account_id}/g" $sql_file > $sql_file_updated

query_string=$(cat "$sql_file_updated")

execution_id=$( aws athena start-query-execution \
  --query-string "$query_string" \
  --work-group nhs-notify-${ENV}-reporting \
  --query-execution-context Database=${glue_database} \
  --result-configuration OutputLocation="s3://nhs-notify-${account_id}-eu-west-2-${ENV}-daily-report/execution_results/${glue_table_name}/" | jq -r '.QueryExecutionId')

echo "Execution ID is: ${execution_id}"

status=$(aws athena get-query-execution --query-execution-id $execution_id | jq -r '.QueryExecution.Status.State')

if [[ $? == 0 ]] && [[ $status != "FAILED" ]]; then
    echo "Table '${glue_table_name}' created!!"
else
    echo "Table creation failed"
    exit 1
fi
