#!/bin/bash
# This script will only allow you to restore to a UAT instance
# run in console like this:
# ./scripts/restore_anon_db.sh [branch-name]
# ./scripts/restore_anon_db.sh ap-2555

echo "Finding pod for branch $1 in UAT"
POD=$(kubectl -n laa-apply-for-legalaid-uat get pods | grep -o -m4 "apply-$1-.*2/2" | head -n1 | cut -d' ' -f 1)
echo "$POD"

echo "Copying anonymised db to kubernetes pod"
kubectl cp ./tmp/production.anon.sql -c web laa-apply-for-legalaid-uat/"$POD":./tmp/anonymised_db.sql

echo "Connect to the pod with kubectl exec and run the rake task"
#kubectl -c web exec apply-ap-2555-anon-uat-db-apply-for-legal-aid-6bb7d68db5-zpx9q -- rake db:import_to_uat
kubectl -c web exec "$POD" -- rake db:import_to_uat

echo "script complete"