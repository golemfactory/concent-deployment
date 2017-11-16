#!/bin/bash -e

./create-config-maps.sh

kubectl create --record --filename services/nginx-proxy.yml
