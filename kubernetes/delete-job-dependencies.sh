#!/bin/bash -e


./find-and-delete-config-maps-or-secrets.sh configmap database-job-settings    || true
./find-and-delete-config-maps-or-secrets.sh secret db-secrets                  || true
./find-and-delete-config-maps-or-secrets.sh secret django-admin-fixture        || true
