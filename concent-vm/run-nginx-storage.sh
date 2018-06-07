#! /bin/bash -e

docker run                       \
    --rm                         \
    --network host               \
    --name nginx-storage         \
    nginx-storage
