#!/bin/bash -e


kubectl delete --filename services/verifier.yml             || true
kubectl delete --filename services/nginx-proxy.yml          || true
kubectl delete --filename services/nginx-storage.yml        || true
kubectl delete --filename services/gatekeeper.yml           || true
kubectl delete --filename services/conductor.yml            || true
kubectl delete --filename services/conductor-worker.yml     || true
kubectl delete --filename services/concent-api-worker.yml   || true
kubectl delete --filename services/concent-api.yml          || true
kubectl delete --filename services/middleman.yml            || true
kubectl delete --filename services/signing-service.yml      || true
kubectl delete --filename services/rabbitmq.yml             || true

./delete-config-maps.sh || true
