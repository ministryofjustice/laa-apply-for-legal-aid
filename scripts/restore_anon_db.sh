#!/bin/bash
# This script will only allow you to restore to a UAT instance

POD=$(kubectl -n laa-apply-for-legalaid-uat get pods | grep -o -m4 "apply-$1-.*2/2" | head -n1 | cut -d' ' -f 1)

echo "Finding pod for branch $1 in UAT"
echo "this is the name of the pod: $POD"

echo "Connect to the pod with kubectl exec and run the rake task"
# connect to the pod and run the psql commands to drop existing and recreate an empty schema
kubectl -c web exec -it "$POD" -- rake db:import_to_uat

echo "script complete"

