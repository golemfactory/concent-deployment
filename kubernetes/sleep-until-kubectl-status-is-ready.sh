#! /bin/bash -e

pod_name=$1
timeout=$2

time_counter=0
until [[ "$(kubectl get $pod_name --output jsonpath='{.status.conditions[?(@.type=="Ready")].status}')" == "True" ]] ; do
    if [[ "$timeout" == "$time_counter" ]]; then
        echo "Timeout has occurred"
        exit 1
    fi

    sleep 1
    time_counter=$((time_counter+1))
done
