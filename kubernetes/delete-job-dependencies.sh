#!/bin/bash -e


kubectl delete configmap database-job-settings              || true
kubectl delete --filename "secrets/control-db-secrets.yml"  || true
kubectl delete --filename "secrets/storage-db-secrets.yml"  || true
kubectl delete secrets django-admin-fixture                 || true
