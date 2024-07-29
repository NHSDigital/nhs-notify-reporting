#!/usr/bin/env bash

# Creates Iceberg table for reporting if it doesn't exist already

ENV=${1:-"no_env"}
account_id=${2:-"no_account"}

if [[ ${ENV} == "no_env" ]] || [[ ${account_id} == "no_account" ]] ; then
    echo "Environment name or Account ID not provided"
    exit 1
fi

glue_database="nhs-notify-${ENV}-reporting-database"
table_name="request_item_plan_summary"

table_exists=$(aws glue get-tables --database-name ${glue_database} | jq 'any(.TableList[].Name == "'${table_name}'"; .)')

if [[ ${table_exists} == "true" ]]; then
    echo "Table already exists for this environment in the database, hence exiting gracefully"
    exit 0
fi

sql_file="./scripts/sql/${table_name}.sql"
sql_file_updated="./scripts/sql/${table_name}_updated.sql"
s3_url="s3://nhs-notify-${account_id}-eu-west-2-${ENV}-reporting"

#Substituting placeholders with actual values and piping to a new sql file to be used as query string
sed "s#\${s3_url}#${s3_url}#g; s#\${table_name}#${table_name}#g" $sql_file > $sql_file_updated

query_string=$(cat "$sql_file_updated")

execution_id=$( aws athena start-query-execution \
  --query-string "$query_string" \
  --work-group nhs-notify-${ENV}-reporting-setupx \
  --query-execution-context Database=${glue_database} \
  --result-configuration OutputLocation="${s3_url}/query_results/setup/${table_name}/" | jq -r '.QueryExecutionId')

if [[ -z "${execution_id}" ]]; then
    echo "Table creation failed"
    exit 1
fi

echo "Execution ID is: ${execution_id}"

status=$(aws athena get-query-execution --query-execution-id $execution_id | jq -r '.QueryExecution.Status.State')

if [[ $? == 0 ]] && [[ $status != "FAILED" ]]; then
    echo "Table '${table_name}' created!!"
else
    echo "Table creation failed"
    exit 1
fi
