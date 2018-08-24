#! /bin/bash -e

kubectl delete --filename templates/nginx-proxy-secrets.yml     || true
kubectl delete --filename templates/nginx-storage-secrets.yml   || true
kubectl delete --filename templates/control-db-secrets.yml      || true
kubectl delete --filename templates/storage-db-secrets.yml      || true
kubectl delete --filename templates/concent-api-secrets.yml     || true
kubectl delete --filename templates/django-admin-fixture.yml    || true
