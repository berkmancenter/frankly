#!/bin/bash

if [ $# -eq 0 ]
then
    echo "Uninstall firestore-bigquery-export extensions for all collections."
    echo "Usage: ./uninstall-extensions.sh [google cloud project id]"
    exit
fi

uninstall_extension () {
  local name=$(sed 's/_/-/g' <<< "$2" )
  firebase ext:uninstall ext-$name --force --project=$1
}

for file in ./collections/*.env; do
  filename="$(basename $file)"
  uninstall_extension $1 "${filename%%.*}" > ./logs/$filename.uninstall.log 2>&1 &
done
