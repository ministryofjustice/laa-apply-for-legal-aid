#!/bin/bash
# This script will allow you to restore to any UAT instance
# run in console and pass in the branch name, or just the start of it:
# ./scripts/restore_anonymised_db.sh [branch-name]
# ./scripts/restore_anonymised_db.sh ap-2555

production_warning() {
  echo "
  -------------------------------------------
  THIS SCRIPT IS NOT TO BE USED ON PRODUCTION
  -------------------------------------------
"
}

help_msg() {
  echo "Usage: db_export.sh [environment]
  Where:
  environment  [staging or a branch name, i.e. ap-1234]"
  exit 1
}

case "$1" in
"production")
  production_warning
  help_msg
  ;;
"")
  help_msg
  ;;
"staging")
  environment=$1
  echo "Finding pod in $environment"
  POD=$(kubectl -n "laa-apply-for-legalaid-$environment" get pods | grep -o -m4 "apply-for-.*2/2" | tail -n1 | cut -d' ' -f 1)
  ;;
*)
  environment='uat'
  echo "Finding pod for branch $1 in $environment"
#  POD=$(kubectl -n laa-apply-for-legalaid-$environment get pods | grep -o -m4 "apply-$1-.*2/2" | head -n1 | cut -d' ' -f 1)
esac

echo "compressing local production backup to speed up upload"
gzip tmp/production.anon.sql -k -3 -f ./tmp/production.anon.sql

echo "Copying anonymised db to kubernetes pod $POD"
kubectl -n laa-apply-for-legalaid-$environment cp --retries=10 ./tmp/production.anon.sql.gz -c web laa-apply-for-legalaid-"$environment"/"$POD":./tmp/anonymised_db.sql.gz

echo "Extracting compressed, uploaded file"
kubectl -n laa-apply-for-legalaid-$environment -c web exec "$POD" -- sh -c 'gunzip ./tmp/anonymised_db.sql.gz'

echo "Importing data..."
kubectl -n laa-apply-for-legalaid-$environment -c web exec "$POD" -- rake db:import_to_uat

if [[ $environment == "staging" ]]; then
  echo "Run seed data to allow portal login"
  kubectl -n laa-apply-for-legalaid-$environment -c web exec "$POD" -- rails db:seed
fi

if [ $? -eq 0 ]; then
   echo 'Restore complete!'
   echo "Deleting the data file from the pod"
   kubectl -n laa-apply-for-legalaid-$environment -c web exec "$POD" -- sh -c 'rm tmp/anonymised_db.sql'
   echo "Deleting local zipped copy"
   rm ./tmp/production.anon.sql.gz
else
   echo "Restore may have failed, check logs before re-running the script"
fi
