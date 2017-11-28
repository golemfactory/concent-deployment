#!/bin/bash -e

kubectl delete --filename secrets/db-secrets.yml  || true
kubectl delete secrets django-admin-fixture       || true
