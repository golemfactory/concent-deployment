#!/bin/bash -e

# Update package lists for Debian and install dependencies
dependencies=(
    python3-pip
    python3-virtualenv
    virtualenv
    libpq-dev
)
apt-get --assume-yes update
apt-get --assume-yes install --no-install-recommends ${dependencies[*]}

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
