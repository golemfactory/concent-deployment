#!/bin/bash -e

# Clear the default `local_settings.py` shipped with the container.
# We're not using it but Django loads it anyway and crashes because it tries to
# import settings from a config map which is not present here.
echo -n "" > "/srv/http/concent_api/concent_api/settings/local_settings.py"

/usr/local/bin/concent-api-manage.sh                  \
    test                                              \
    --failfast                                        \
    --settings=concent_api.settings.docker_testing
