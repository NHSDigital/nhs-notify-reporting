#!/usr/bin/env bash

# Executes an athena query

query_string=$1
workgroup=$2
glue_database=$3

if [[ -z "${query_string}" ]];  then
    echo "Query string not specified"
    exit 1
fi

if [[ -z "${workgroup}" ]]; then
    echo "Athena workgroup not specified"
    exit 1
fi

if [[ -z "${glue_database}" ]]; then
    echo "Glue database not specified"
    exit 1
fi

execution_id=$( aws athena start-query-execution \
  --query-string "${query_string}" \
  --work-group ${workgroup} \
  --query-execution-context Database=${glue_database} | jq -r '.QueryExecutionId')

if [[ -z "${execution_id}" ]]; then
    echo "Query execution failed"
    exit 1
fi

echo "Execution ID is: ${execution_id}"

while
  status=$(aws athena get-query-execution --query-execution-id $execution_id | jq -r '.QueryExecution.Status.State')
  [[ $? == 0 ]] && [[ $status != "FAILED" ]] && [[ $status != "SUCCEEDED" ]]
do
  :
done

if [[ $? == 0 ]] && [[ $status == "SUCCEEDED" ]]; then
    echo "Query execution succeeded"
    exit 0
else
    echo "Query execution failed"
    exit 1
fi
