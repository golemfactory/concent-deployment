#!/bin/bash -e

concent_dir=$1
output_dir=$2

build/virtualenv/bin/python3 "build/virtualenv/src/golem-messages/version.py"
mv RELEASE-VERSION "$concent_dir"

tar                                            \
    --create                                   \
    --verbose                                  \
    --file="$output_dir/concent-api.tar"       \
    --directory="$concent_dir"                 \
    concent_api/                               \
    RELEASE-VERSION
