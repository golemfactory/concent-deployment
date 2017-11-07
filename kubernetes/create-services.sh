#!/bin/bash -e

./create-config-maps.sh

kubectl create --record --filename services/mail-relay.yml
kubectl create --record --filename services/concent-api.yml
kubectl create --record --filename services/nginx-proxy.yml
