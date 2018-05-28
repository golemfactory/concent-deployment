#!/bin/bash -e

# This variable can contain only two values: configmap or secret.
resource_type=$1
# This variable can contain name of config map or secret without suffix.
prefix_name=$2

if [[ "$resource_type" == "configmap" ]]; then
    configmap_name=$(kubectl get configmaps | grep "^$prefix_name" | awk '{print $1}')
    kubectl delete configmaps $configmap_name
elif [[ "$resource_type" == "secret" ]]; then
    secret_name=$(kubectl get secrets | grep "^$prefix_name" | awk '{print $1}')
    kubectl delete secrets $secret_name
else
    echo "The specified resource type is not valid"
    exit 1
fi
