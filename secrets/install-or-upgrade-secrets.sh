#!/bin/bash

helm upgrade --dry-run  concent-api-secrets concent-api-secrets/ > /dev/null 2>&1
exitstatus=$?

if [ "$exitstatus" -ne "0" ]; then
	echo "creating secrets"
	helm install --name concent-api-secrets concent-api-secrets/
else
	echo "upgrading secrets"
	helm upgrade concent-api-secrets concent-api-secrets/
fi
