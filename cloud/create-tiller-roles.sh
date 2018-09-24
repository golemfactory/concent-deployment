#! /bin/bash -e

# Confirm executing script
read -p "Make sure your kubectl is set in properly environment(cluster)[y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

    # Create namespace and serviceaccout for tiller
    kubectl create namespace tiller
    kubectl create serviceaccount tiller --namespace tiller

    # Add your user to `cluster-admin` role which is needed for create roles.
    # Create roles for tiller
    kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
    kubectl create -f role-tiller.yml
fi
