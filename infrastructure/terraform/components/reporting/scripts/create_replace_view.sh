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

shift 3
if (( $# % 2 != 0 )); then
  echo "Extra arguments must come in pairs (got $#)."
  exit 1
fi

sql_file="./scripts/sql/views/${view_name}.sql"

#Substituting placeholders with actual values
sed -i "s#\${view_name}#${view_name}#g" $sql_file

# Variable args as k/v pairs
while (( "$#" )); do
  sed -i "s#\${$1}#$2#g" $sql_file
  shift 2
done

query_string=$(cat "$sql_file")
echo $query_string

$(dirname "$0")/execute_query.sh "${query_string}" ${workgroup} ${glue_database}

if [[ $? == 0 ]]; then
    echo "View ${view_name} created or replaced successfully"
    exit 0
else
    echo "View creation failed"
    exit 1
fi
