#!/bin/bash

if [ $# -eq 0 ]
then
    echo "Update BigQuery schema views, using schema files from ./generated_schemas."
    echo "Usage: ./update-views.sh [google cloud project id]"
    exit
fi

process_collection_env () {
  local filename="$(basename $file)"
  local table=$(awk -F'=' '/^TABLE_ID/ { print $2 }' $2)
  local datasetid=$(awk -F'=' '/^DATASET_ID/ { print $2 }' $2)
  local schemafile="./generated_schemas/${table%%.*}.json";
  if [ -f "$schemafile" ]; then
    npx @firebaseextensions/fs-bq-schema-views --non-interactive --project $1 --dataset $datasetid --table-name-prefix $table --schema-files $schemafile
  fi
}

npm i @firebaseextensions/fs-bq-schema-views

for file in ./collections/*.env; do
  filename="$(basename $file)"
  process_collection_env $1 $file > ./logs/$filename.schema.log 2>&1
done
