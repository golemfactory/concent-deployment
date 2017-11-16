#!/bin/bash -e

kubectl create secret generic concent-api-secrets            \
    --from-file=secrets.py=concent-secrets/secrets.py        \
    --from-literal=__init__.py=

kubectl create configmap nginx-config                               \
    --from-file=default.conf=config-maps/nginx-proxy/default.conf

kubectl create configmap concent-api-settings                                \
    --from-file=local_settings.py=config-maps/concent-api/local_settings.py  \
    --from-literal=__init__.py=
