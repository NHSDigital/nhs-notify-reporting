#!/usr/bin/env bash

# Adds a column to an existing table if it doesn't already exist

environment=$1
table_name=$2
column_name=$3
column_datatype=$4

if [[ -z "${environment}" ]];  then
    echo "Environment name not specified"
    exit 1
fi

if [[ -z "${table_name}" ]]; then
    echo "Table name not specified"
    exit 1
fi

if [[ -z "${column_name}" ]]; then
    echo "Column name not specified"
    exit 1
fi

if [[ -z "${column_datatype}" ]]; then
    echo "Column data type not specified"
    exit 1
fi

# glue_database="nhs-notify-${environment}-reporting-database"
glue_database="comms-${environment}-api-rpt-reporting"

table_exists=$(aws glue get-tables --database-name ${glue_database} | jq 'any(.TableList[].Name == "'${table_name}'"; .)')

if [[ ${table_exists} != "true" ]]; then
    echo "Table ${table_name} does not exist in database ${glue_database}"
    exit 1
fi

column_exists=$(aws glue get-tables --database-name ${glue_database} | \
    jq '.TableList[] | select (.Name=="'${table_name}'") | any(.StorageDescriptor.Columns[].Name == "'${column_name}'"; .)')

if [[ ${column_exists} == "true" ]]; then
    echo "Column already exists for this table in the database, no further action required"
    exit 0
fi

: '
sql_file="./scripts/sql/tables/${table_name}.sql"
sql_file_updated="./scripts/sql/tables/${table_name}_updated.sql"
s3_location="s3://${s3_bucket}/${table_name}"

#Substituting placeholders with actual values and piping to a new sql file to be used as query string
sed "s#\${s3_location}#${s3_location}#g; s#\${table_name}#${table_name}#g" $sql_file > $sql_file_updated

query_string=$(cat "$sql_file_updated")

execution_id=$( aws athena start-query-execution \
  --query-string "$query_string" \
  --work-group nhs-notify-${environment}-reporting-setup \
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
'
