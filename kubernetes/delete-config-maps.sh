#!/bin/bash -e

kubectl delete --wait=true --timeout=30s --ignore-not-found=true configmap nginx-storage-configs
kubectl delete --wait=true --timeout=30s --ignore-not-found=true configmap file-transfer-config
kubectl delete --wait=true --timeout=30s --ignore-not-found=true configmap nginx-configs
kubectl delete --wait=true --timeout=30s --ignore-not-found=true configmap nginx-settings
kubectl delete --wait=true --timeout=30s --ignore-not-found=true configmap gatekeeper-settings
kubectl delete --wait=true --timeout=30s --ignore-not-found=true configmap conductor-settings
kubectl delete --wait=true --timeout=30s --ignore-not-found=true configmap conductor-worker-settings
kubectl delete --wait=true --timeout=30s --ignore-not-found=true configmap concent-api-settings
kubectl delete --wait=true --timeout=30s --ignore-not-found=true configmap concent-api-worker-settings
kubectl delete --wait=true --timeout=30s --ignore-not-found=true configmap verifier-settings
kubectl delete --wait=true --timeout=30s --ignore-not-found=true configmap middleman-settings
