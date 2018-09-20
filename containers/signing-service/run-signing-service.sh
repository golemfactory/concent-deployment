#! /bin/bash -e

cd /usr/lib/signing_service/signing-service/
source /usr/lib/signing_service/virtualenv/bin/activate
./signing_service.sh $@
