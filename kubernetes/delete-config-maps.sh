#!/bin/bash -e

kubectl delete configmap nginx-config         || true
kubectl delete configmap concent-api-settings || true
kubectl delete secret concent-api-secrets     || true
