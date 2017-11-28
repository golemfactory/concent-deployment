#!/bin/bash -e

kubectl delete job create-database  || true
kubectl delete job delete-database  || true
kubectl delete job migrate-database || true

./delete-job-depedencies.sh || true
