#! /bin/bash -e

# Confirm executing script
read -p "Make sure your kubectl is set in properly environment(cluster)[y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

    # Create namespace and serviceaccout for tiller
    kubectl create namespace tiller
    kubectl create serviceaccount tiller --namespace tiller

    # Create roles for tiller
    kubectl create -f role-tiller.yml
fi
