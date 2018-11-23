#!/bin/bash -e

source concent-env.sh
cd concent_api/

django_database_names=(
    control
    storage
)

for django_db_name in "${django_database_names[@]}"; do
    ./manage.py migrate --database=$django_db_name
done
