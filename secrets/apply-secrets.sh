#! /bin/bash -e

kubectl apply --filename templates/nginx-proxy-secrets.yml
kubectl apply --filename templates/nginx-storage-secrets.yml
kubectl apply --filename templates/control-db-secrets.yml
kubectl apply --filename templates/storage-db-secrets.yml
kubectl apply --filename templates/concent-api-secrets.yml
kubectl apply --filename templates/django-admin-fixture.yml
