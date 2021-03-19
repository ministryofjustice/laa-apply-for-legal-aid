#!/bin/bash

declare -a envs=("staging" "production")

case "$1" in
"staging")
  environment=$1
  POD=$(kubectl -n "laa-apply-for-legalaid-$environment" get pods | grep -o -m4 "apply-for-.*2/2" | tail -n1 | cut -d' ' -f 1)
  ;;
"production")
  environment=$1
  POD=$(kubectl -n "laa-apply-for-legalaid-$environment" get pods | grep -o -m4 "apply-for-.*2/2" | tail -n1 | cut -d' ' -f 1)
 ;;
"")
  echo "Usage: db_export.sh [environment]
Where:
environment  [staging, production or a branch name, i.e. ap-1234]"
  exit 1
  ;;
*)
  environment='uat'
  POD=$(kubectl -n laa-apply-for-legalaid-uat get pods | grep -o -m4 "apply-$1-.*2/2" | head -n1 | cut -d' ' -f 1)
esac

echo "Finding pod for $environment"
echo "Connecting to $POD, anonymizing, compressing and exporting DB"
kubectl -n laa-apply-for-legalaid-$environment -c web exec "$POD" -- rake db:export
kubectl -n laa-apply-for-legalaid-$environment cp -c web "laa-apply-for-legalaid-$environment/$POD:tmp/temp.sql.gz" "./tmp/$environment.anon.sql.gz"
gunzip "./tmp/$environment.anon.sql.gz"
cat << INSTRUCTIONS
Do you care about the current state of your dev DB? read on, otherwise skip to step 2

1. Take a backup of your current local dev database
   pg_dump apply_for_legal_aid_dev > ~/Downloads/local_dev_apply_db.sql

2. Delete the current, local database
   psql -q -d apply_for_legal_aid_dev -c "drop schema public cascade"
   psql -q -d apply_for_legal_aid_dev -c "create schema public"

3. Restore the staging database
   psql -q -P pager=off -d apply_for_legal_aid_dev -f ./tmp/$environment.anon.sql
INSTRUCTIONS
