#!/bin/bash -e

kubectl delete configmap nginx-config-snippets || true
kubectl delete secret nginx-storage-secrets    || true
kubectl delete configmap nginx-storage-configs || true
kubectl delete secret nginx-proxy-secrets      || true
kubectl delete configmap nginx-configs         || true
kubectl delete configmap gatekeeper-settings   || true
kubectl delete configmap conductor-settings    || true
kubectl delete configmap concent-api-settings  || true
kubectl delete configmap verifier-settings     || true
kubectl delete secret concent-api-secrets      || true
