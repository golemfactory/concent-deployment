#! /bin/sh -e

# Run crond
crond -f &
# Run nginx
/usr/local/openresty/bin/openresty -g "daemon off;"
