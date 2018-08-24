#!/bin/bash -e

cluster_type=$1

kubectl create configmap database-job-settings                                \
    --from-file=local_settings.py=config-maps/database-jobs/local_settings.py \
    --from-literal=__init__.py=
