#!/bin/bash -e

concent_dir=$1
output_dir=$2

deployment_dir="../concent-deployment/containers"

cd "$concent_dir/"

# FIXME: The current version of `version.sh` script in golem-messages can't handle tags with hyphens.
# See https://github.com/golemfactory/golem-messages/issues/194.
# As a temporary workaround, we're calling `git describe` directly here.
#"$deployment_dir/build/virtualenv/bin/python3" "$deployment_dir/build/virtualenv/src/golem-messages/version.py"
echo -n "git describe --tags" >> RELEASE-VERSION

cd "$deployment_dir/"
tar                                            \
    --create                                   \
    --verbose                                  \
    --file="$output_dir/concent-api.tar"       \
    --directory="$concent_dir"                 \
    concent_api/                               \
    RELEASE-VERSION
