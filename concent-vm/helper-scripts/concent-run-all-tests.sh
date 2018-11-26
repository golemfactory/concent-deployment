#! /bin/bash -e

source concent-env.sh
./full-check.sh
./api-e2e-tests.sh
