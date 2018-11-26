#!/bin/bash -e

source concent-env.sh
source ~/signing-service-env.sh

function run_signing_service {
    cd ../signing_service/
    ./signing_service.sh                                                                                                 \
        --concent-cluster-host 127.0.0.1                                                                                 \
        --concent-public-key 85cZzVjahnRpUBwm0zlNnqTdYom1LF1P1WNShLg17cmhN2UssnPrCjHKTi5susO3wrr/q07eswumbL82b4HgOw==    \
        --concent-cluster-port 9055                                                                                      \
        --ethereum-private-key-from-env                                                                                  \
        --signing-service-private-key-from-env
}


cd concent_api/

# `kill 0` sends SIGTERM to the whole process group started by the current process.
# We're doing this when we catch a signal from Ctrl+C because otherwise the child processes
# we're starting below would keep running in the background.
trap "kill 0" SIGINT

django_runserver_and_celery_command="$(
    celery worker                                   \
        --app      concent_api                      \
        --hostname concent                          \
        --queues   concent &                        \
                                                    \
    celery worker                                   \
        --app      concent_api                      \
        --hostname conductor                        \
        --queues   conductor &                      \
                                                    \
    celery worker                                   \
        --app      concent_api                      \
        --queues   verifier &                       \
                                                    \
    python manage.py runserver 0.0.0.0:8000 &       \
                                                    \
    python manage.py middleman                      \
        --bind          0.0.0.0                     \
        --internal-port 9054                        \
        --external-port 9055 &                      \
                                                    \
    run_signing_service &                           \
)"

$django_runserver_and_celery_command
