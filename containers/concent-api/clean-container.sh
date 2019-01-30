#!/bin/bash -e


readarray temporary_dependencies < ${BASH_SOURCE%/*}/build-dependencies.txt

# Clean up
apt-get clean
apt autoremove --assume-yes
apt-get remove --purge --assume-yes ${temporary_dependencies[*]}

rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
