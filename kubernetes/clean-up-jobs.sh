#!/bin/bash -e

kubectl delete job reset-control-database   || true
kubectl delete job reset-storage-database   || true
kubectl delete job migrate-control-database || true
kubectl delete job migrate-storage-database || true
