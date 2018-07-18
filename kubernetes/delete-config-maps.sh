#!/bin/bash -e

kubectl delete configmap nginx-config-snippets        || true
kubectl delete configmap nginx-storage-configs        || true
kubectl delete configmap file-transfer-config         || true
kubectl delete configmap nginx-configs                || true
kubectl delete configmap nginx-settings               || true
kubectl delete configmap gatekeeper-settings          || true
kubectl delete configmap conductor-settings           || true
kubectl delete configmap conductor-worker-settings    || true
kubectl delete configmap concent-api-settings         || true
kubectl delete configmap concent-api-worker-settings  || true
kubectl delete configmap verifier-settings            || true
kubectl delete configmap middleman-settings           || true
