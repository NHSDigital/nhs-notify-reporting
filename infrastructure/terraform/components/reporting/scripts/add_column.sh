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

glue_database="nhs-notify-${environment}-reporting-database"

table_exists=$(aws glue get-tables --database-name ${glue_database} | jq 'any(.TableList[].Name == "'${table_name}'"; .)')

if [[ ${table_exists} != "true" ]]; then
    echo "Table ${table_name} does not exist in database ${glue_database}"
    exit 1
fi

column_exists=$(aws glue get-tables --database-name ${glue_database} | \
    jq 'any(.TableList[] | select (.Name=="'${table_name}'") | .StorageDescriptor.Columns[] | select (.Name=="'${column_name}'") | select (.Parameters."iceberg.field.current"=="true"); .)')

if [[ ${column_exists} == "true" ]]; then
    echo "Column already exists for this table in the database, no further action required"
    exit 0
fi

query_string="ALTER TABLE ${table_name} ADD COLUMNS (${column_name} ${column_datatype})"

$(dirname "$0")/execute_query.sh "${query_string}" nhs-notify-${environment}-reporting-setup ${glue_database}

if [[ $? == 0 ]]; then
    echo "Column ${column_name} added to table ${table_name}"
    exit 0
else
    echo "Column failed"
    exit 1
fi
