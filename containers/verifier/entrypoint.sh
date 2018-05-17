#!/bin/bash -e

exec /usr/local/bin/su-exec nobody /bin/bash -c "$@"
