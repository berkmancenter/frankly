#!/bin/bash

if [ $# -eq 0 ]
then
  echo "Install firestore-bigquery-export extensions for all collections, and import existing data."
  echo "Usage: ./install-extensions.sh [google cloud project id]"
  exit
fi

install_extension () {
  local name=$(sed 's/_/-/g' <<< "$2" )
  expect <<EOD
set timeout -1
spawn firebase ext:install firebase/firestore-bigquery-export --force --params=./collections/$2.env --project=$1

expect "Please enter a new name for this instance:"
send -- "ext-$name\r"

expect eof
EOD
}

process_collection_env () {
  local filename="$(basename $file)"
  install_extension $1 "${filename%%.*}"
  local collection=$(awk -F'=' '/^COLLECTION_PATH/ { print $2 }' $2)
  local collectionname=$(awk -F "/" '{print $NF}' <<< $collection)
  local table=$(awk -F'=' '/^TABLE_ID/ { print $2 }' $2)
  local datasetid=$(awk -F'=' '/^DATASET_ID/ { print $2 }' $2)
  local datasetlocation=$(awk -F'=' '/^DATASET_LOCATION/ { print $2 }' $2)
  local collectiongroup="false"
  if [[ $collection =~ "{" ]]; then
    collectiongroup="true"
  fi
  npx @firebaseextensions/fs-bq-import-collection --non-interactive --project $1 --source-collection-path $collectionname --query-collection-group $collectiongroup --dataset $datasetid --table-name-prefix $table --dataset-location $datasetlocation
}

npm i @firebaseextensions/fs-bq-import-collection

for file in ./collections/*.env; do
  filename="$(basename $file)"
  process_collection_env $1 $file > ./logs/$filename.install.log 2>&1 &
done
