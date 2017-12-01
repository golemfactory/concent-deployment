#!/bin/bash -e

./create-config-maps.sh

kubectl create --record --filename services/concent-api.yml
kubectl create --record --filename services/nginx-storage.yml
kubectl create --record --filename services/nginx-proxy.yml
