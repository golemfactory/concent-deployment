#!/bin/bash -e

kubectl delete configmap database-job-settings              || true
