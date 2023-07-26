#!/bin/bash
# This script will allow you to restore to any UAT instance
# run in console and pass in the branch name, or just the start of it:
# ./scripts/restore_anonymised_db.sh [branch-name]
# ./scripts/restore_anonymised_db.sh ap-2555

echo "Finding pod for branch $1 in UAT"
POD=$(kubectl -n laa-apply-for-legalaid-uat get pods | grep -o -m4 "apply-$1-.*2/2" | head -n1 | cut -d' ' -f 1)
echo "$POD"

echo "Copying anonymised db to kubernetes pod..."
kubectl -n laa-apply-for-legalaid-uat cp --retries=10 ./tmp/production.anon.sql -c web laa-apply-for-legalaid-uat/"$POD":./tmp/anonymised_db.sql

echo "Importing data..."
kubectl -n laa-apply-for-legalaid-uat -c web exec "$POD" -- rake db:import_to_uat

if [ $? -eq 0 ]; then
   echo 'Restore complete!'
   echo "Deleting the data file from the pod"
   kubectl -n laa-apply-for-legalaid-uat -c web exec "$POD" -- sh -c 'rm tmp/anonymised_db.sql'
else
   echo "Restore may have failed, check logs before re-running the script"
fi
