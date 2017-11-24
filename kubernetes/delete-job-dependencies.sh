#!/bin/bash -e

kubectl delete --filename secrets/db-secrets.yml
kubectl delete secrets django-admin-fixture
