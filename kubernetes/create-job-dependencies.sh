#!/bin/bash -e

cluster_type=$1

kubectl create configmap database-job-settings                                \
    --from-file=local_settings.py=config-maps/database-jobs/local_settings.py \
    --from-literal=__init__.py=
kubectl create --filename "secrets/$cluster_type-db-secrets.yml"
if [[ $cluster_type == "control" ]]; then
kubectl create secret generic django-admin-fixture \
    --from-file=django-admin-fixture.yaml=secrets/django-admin-fixture.yaml
fi
