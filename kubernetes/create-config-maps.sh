#!/bin/bash -e


kubectl create configmap nginx-config-snippets                          \
    --from-file=error-pages.conf=config-maps/nginx/error-pages.conf

kubectl create configmap nginx-storage-config                           \
    --from-file=default.conf=config-maps/nginx-storage/default.conf     \

kubectl create secret generic concent-api-secrets            \
    --from-file=secrets.py=concent-secrets/secrets.py        \
    --from-literal=__init__.py=

kubectl create configmap nginx-config                               \
    --from-file=default.conf=config-maps/nginx-proxy/default.conf

kubectl create configmap concent-api-settings                                \
    --from-file=local_settings.py=config-maps/concent-api/local_settings.py  \
    --from-literal=__init__.py=

kubectl create configmap gatekeeper-settings                               \
    --from-file=local_settings.py=config-maps/gatekeeper/local_settings.py \
    --from-literal=__init__.py=
