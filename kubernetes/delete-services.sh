#!/bin/bash -e

kubectl delete --filename services/nginx-proxy.yml || true
kubectl delete --filename services/concent-api.yml || true

./delete-config-maps.sh
