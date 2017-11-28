#!/bin/bash -e

kubectl create --filename secrets/db-secrets.yml
kubectl create secret generic django-admin-fixture \
    --from-file=django-admin-fixture.yaml=secrets/django-admin-fixture.yaml
