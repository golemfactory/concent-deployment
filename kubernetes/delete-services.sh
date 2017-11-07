#!/bin/bash -e

kubectl delete --filename services/nginx-proxy.yml || true
kubectl delete --filename services/concent-api.yml || true
kubectl delete --filename services/mail-relay.yml  || true

./delete-config-maps.sh
