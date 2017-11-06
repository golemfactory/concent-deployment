#!/bin/bash -e

kubectl create --record --filename services/nginx-proxy.yml
