#!/bin/bash -e

cd "/srv/http/concent_api"

exec "/srv/http/virtualenv/bin/celery" worker    \
    --app=concent_api                            \
    --loglevel=INFO
