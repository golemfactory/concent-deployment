#!/bin/bash -e

./find-and-delete-config-maps-or-secrets.sh configmap nginx-config-snippets || true
./find-and-delete-config-maps-or-secrets.sh secret nginx-storage-secrets    || true
./find-and-delete-config-maps-or-secrets.sh configmap nginx-storage-configs || true
./find-and-delete-config-maps-or-secrets.sh secret nginx-proxy-secrets      || true
./find-and-delete-config-maps-or-secrets.sh configmap nginx-configs         || true
./find-and-delete-config-maps-or-secrets.sh configmap gatekeeper-settings   || true
./find-and-delete-config-maps-or-secrets.sh configmap conductor-settings    || true
./find-and-delete-config-maps-or-secrets.sh configmap concent-api-settings  || true
./find-and-delete-config-maps-or-secrets.sh configmap verifier-settings     || true
./find-and-delete-config-maps-or-secrets.sh secret concent-api-secrets      || true


