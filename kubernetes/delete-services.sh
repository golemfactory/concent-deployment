#!/bin/bash -e


kubectl delete --filename services/nginx-proxy.yml   || true
kubectl delete --filename services/nginx-storage.yml || true
kubectl delete --filename services/gatekeeper.yml    || true
kubectl delete --filename services/concent-api.yml   || true
kubectl delete --filename services/rabbitmq.yml      || true
kubectl delete --filename services/geth.yml          || true

./delete-config-maps.sh || true
