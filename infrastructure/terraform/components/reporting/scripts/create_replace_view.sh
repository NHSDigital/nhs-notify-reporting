#!/usr/bin/env bash

# Creates or replaces a view

workgroup=$1
glue_database=$2
view_name=$3

if [[ -z "${workgroup}" ]]; then
    echo "Athena workgroup not specified"
    exit 1
fi

if [[ -z "${glue_database}" ]]; then
    echo "Glue database not specified"
    exit 1
fi

if [[ -z "${view_name}" ]]; then
    echo "View name not specified"
    exit 1
fi

sql_file="./scripts/sql/views/${view_name}.sql"
sql_file_updated="./scripts/sql/views/${view_name}_updated.sql"

#Substituting placeholders with actual values and piping to a new sql file to be used as query string
sed "s#\${view_name}#${view_name}#g" $sql_file > $sql_file_updated

query_string=$(cat "$sql_file_updated")

$(dirname "$0")/execute_query.sh "${query_string}" ${workgroup} ${glue_database}

if [[ $? == 0 ]]; then
    echo "View ${view_name} created or replaced successfully"
    exit 0
else
    echo "View creation failed"
    exit 1
fi
