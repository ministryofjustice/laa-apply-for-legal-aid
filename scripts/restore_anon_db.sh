#!/bin/bash
# This script will only allow you to restore to a UAT instance
# run in console like this:
# ./scripts/restore_anon_db.sh [branch-name]  "$(< [path/to/sql/file])"
# ./scripts/restore_anon_db.sh ap-2555  "$(< ./scripts/uat.anon.sql)"
# Find the pod with the branch-name
POD=$(kubectl -n laa-apply-for-legalaid-uat get pods | grep -o -m4 "apply-$1-.*2/2" | head -n1 | cut -d' ' -f 1)
echo "Finding pod for branch $1 in UAT"

#connect to the pod and copy the sql file across to tmp folder
echo "start copying"
#kubectl cp ./scripts/uat.anon.sql -c web laa-apply-for-legalaid-uat/"$POD":/tmp/anon.sql
#kubectl -n laa-apply-for-legalaid-uat cp -c web "laa-apply-for-legalaid-$environment/$POD:tmp/temp.sql.gz" "./tmp/$environment.anon.sql.gz"

kubectl cp ./scripts/uat.anon.sql -c web laa-apply-for-legalaid-uat/apply-ap-2555-anon-uat-db-apply-for-legal-aid-98877695c-j9l7k:./tmp/anon3.sql
#kubectl cp ./scripts/uat.anon.sql -c web laa-apply-for-legalaid-uat/apply-ap-2555-anon-uat-db-apply-for-legal-aid-98877695c-j9l7k:./tmp/anon.sql

echo "Connect to the pod with kubectl exec and run the rake task"
# connect to the pod and run the psql commands to drop existing and recreate an empty schema
#kubectl -c web exec -it "$POD" -- rake db:import_to_uat
kubectl -c web exec apply-ap-2555-anon-uat-db-apply-for-legal-aid-98877695c-j9l7k -- rake db:import_to_uat

echo "script complete"