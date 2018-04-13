#!/bin/bash -e

concent_dir=$1
output_dir=$2

deployment_dir="../concent-deployment/containers"

cd "$concent_dir/"
"$deployment_dir/build/virtualenv/bin/python3" "$deployment_dir/build/virtualenv/src/golem-messages/version.py"

cd "$deployment_dir/"
tar                                            \
    --create                                   \
    --verbose                                  \
    --file="$output_dir/concent-api.tar"       \
    --directory="$concent_dir"                 \
    concent_api/                               \
    RELEASE-VERSION
