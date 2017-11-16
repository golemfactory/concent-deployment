#!/bin/bash -e

cd "/srv/http/concent_api"
source "/srv/http/virtualenv/bin/activate"
./manage.py "$@"
