#!/bin/bash -e

readarray temporary_dependencies <<< $(cat ${BASH_SOURCE%/*}/build-dependencies.txt ${BASH_SOURCE%/*}/pyenv-build-dependencies.txt)

# Clean up
apt-get clean
apt-get remove --purge --assume-yes ${temporary_dependencies[*]}
apt autoremove --assume-yes

rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache/pip/*
