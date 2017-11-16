#!/bin/bash -e

kubectl create configmap nginx-config                               \
    --from-file=default.conf=config-maps/nginx-proxy/default.conf
