#!/usr/bin/env bash

# Creates table if it doesn't already exist

workgroup=$1
glue_database=$2
s3_bucket=$3
table_name=$4

if [[ -z "${workgroup}" ]]; then
    echo "Athena workgroup not specified"
    exit 1
fi

if [[ -z "${glue_database}" ]]; then
    echo "Glue database not specified"
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

table_exists=$(aws glue get-tables --database-name ${glue_database} | jq 'any(.TableList[].Name == "'${table_name}'"; .)')

if [[ ${table_exists} == "true" ]]; then
    echo "Table already exists for this environment in the database, no further action required"
    exit 0
fi

sql_file="./scripts/sql/tables/${table_name}.sql"
sql_file_updated="./scripts/sql/tables/${table_name}_updated.sql"
s3_location="s3://${s3_bucket}/${table_name}"

#Substituting placeholders with actual values and piping to a new sql file to be used as query string
sed "s#\${s3_location}#${s3_location}#g; s#\${table_name}#${table_name}#g" $sql_file > $sql_file_updated

query_string=$(cat "$sql_file_updated")

$(dirname "$0")/execute_query.sh "${query_string}" ${workgroup} ${glue_database}

if [[ $? == 0 ]]; then
    echo "Table ${table_name} created successfully"
    exit 0
else
    echo "Table creation failed"
    exit 1
fi
