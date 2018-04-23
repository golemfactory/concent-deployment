#!/bin/bash -e

./create-config-maps.sh

kubectl create --record --filename services/verifier.yml
./wait-until-ready.sh verifier 70
kubectl create --record --filename services/geth.yml
kubectl create --record --filename services/rabbitmq.yml
kubectl create --record --filename services/concent-api.yml
kubectl create --record --filename services/gatekeeper.yml
kubectl create --record --filename services/conductor.yml
kubectl create --record --filename services/nginx-storage.yml
kubectl create --record --filename services/nginx-proxy.yml
./wait-until-ready.sh geth          60
./wait-until-ready.sh rabbitmq      60
./wait-until-ready.sh concent-api   30
./wait-until-ready.sh gatekeeper    30
./wait-until-ready.sh conductor     30
./wait-until-ready.sh nginx-storage 30
./wait-until-ready.sh nginx-proxy   30
