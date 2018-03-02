#!/bin/bash -e

kubectl delete configmap nginx-config-snippets || true
kubectl delete configmap nginx-storage-config  || true
kubectl delete configmap nginx-config          || true
kubectl delete configmap gatekeeper-settings   || true
kubectl delete configmap concent-api-settings  || true
kubectl delete secret concent-api-secrets      || true
