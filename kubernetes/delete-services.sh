#!/bin/bash -e


kubectl delete --wait=true --timeout=30s --ignore-not-found=true --filename services/verifier.yml
kubectl delete --wait=true --timeout=30s --ignore-not-found=true --filename services/nginx-proxy.yml
kubectl delete --wait=true --timeout=30s --ignore-not-found=true --filename services/nginx-storage.yml
kubectl delete --wait=true --timeout=30s --ignore-not-found=true --filename services/gatekeeper.yml
kubectl delete --wait=true --timeout=30s --ignore-not-found=true --filename services/conductor.yml
kubectl delete --wait=true --timeout=30s --ignore-not-found=true --filename services/conductor-worker.yml
kubectl delete --wait=true --timeout=30s --ignore-not-found=true --filename services/concent-api-worker.yml
kubectl delete --wait=true --timeout=30s --ignore-not-found=true --filename services/concent-api.yml
kubectl delete --wait=true --timeout=30s --ignore-not-found=true --filename services/middleman.yml
kubectl delete --wait=true --timeout=30s --ignore-not-found=true --filename services/signing-service.yml
kubectl delete --wait=true --timeout=30s --ignore-not-found=true --filename services/rabbitmq.yml
kubectl delete --wait=true --timeout=30s --ignore-not-found=true --filename services/geth.yml
kubectl wait --for=delete pods --all || true

./delete-config-maps.sh || true
