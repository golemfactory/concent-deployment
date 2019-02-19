#! /bin/bash -e

job_name=$1
timeout=$2

time_counter=0
until [[ "$(kubectl get job $job_name --output jsonpath='{.status.conditions[?(@.type=="Complete")].status}')" == "True" ]] ; do
    if [[ "$timeout" == "$time_counter" ]]; then
        echo "Timeout: job \"$job_name\" has not completed in \"$timeout\". Not waiting any longer."
        exit 1
    fi

    sleep 1
    time_counter=$((time_counter+1))
done
