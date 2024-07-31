#!/usr/bin/env bash

# Creates table if it doesn't exist already

ENV=${1:-"no_env"}
s3_bucket=$2
table_name=$3

if [[ ${ENV} == "no_env" ]]; then
    echo "Environment name not provided"
    exit 1
fi

if [[ -z "${s3_bucket}" ]]; then
    echo "S3 bucket not specified"
    exit 1
fi

if [[ -z "${table_name}" ]]; then
    echo "Table name not specified"
    exit 1
fi

glue_database="nhs-notify-${ENV}-reporting-database"

table_exists=$(aws glue get-tables --database-name ${glue_database} | jq 'any(.TableList[].Name == "'${table_name}'"; .)')

if [[ ${table_exists} == "true" ]]; then
    echo "Table already exists for this environment in the database, no further action required"
    exit 0
fi

sql_file="./scripts/sql/tables/${table_name}.sql"
sql_file_updated="./scripts/sql/tables/${table_name}_updated.sql"
s3_root="s3://${s3_bucket}"
s3_location="${s3_root}/data/${table_name}"

#Substituting placeholders with actual values and piping to a new sql file to be used as query string
sed "s#\${s3_location}#${s3_location}#g; s#\${table_name}#${table_name}#g" $sql_file > $sql_file_updated

query_string=$(cat "$sql_file_updated")

execution_id=$( aws athena start-query-execution \
  --query-string "$query_string" \
  --work-group nhs-notify-${ENV}-reporting-setup \
  --query-execution-context Database=${glue_database} | jq -r '.QueryExecutionId')

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
