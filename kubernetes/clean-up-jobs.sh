#!/bin/bash -e

kubectl delete job reset-database   || true
kubectl delete job migrate-database || true
