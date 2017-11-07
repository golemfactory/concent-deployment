#!/bin/bash -e

concent_dir=$1
output_dir=$2

tar                                            \
    --create                                   \
    --verbose                                  \
    --file="$output_dir/concent-api.tar"       \
    --directory="$concent_dir"                 \
    concent_api/
