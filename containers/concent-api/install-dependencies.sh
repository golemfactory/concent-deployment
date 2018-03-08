#!/bin/bash -e

# Update package lists for Debian and install dependencies
dependencies=(
    # Required by psycopg2 python package (PostgreSQL support)
    libpq-dev

    # Packages needed to build python extensions, dependencies of golem-messages in particular
    gcc
    libssl-dev
    git
    pkg-config
    libsecp256k1-dev
    libffi-dev
    software-properties-common
)

testing_dependencies=(
    # There's no stable Python 3.6 package in Debian Stretch yet so we have to get it from testing.
    python3.6
    python3.6-dev
    virtualenv
)

apt-get update --assume-yes
apt-get install              \
    --assume-yes             \
    --no-install-recommends  \
    ${dependencies[*]}

add-apt-repository "deb http://ftp.de.debian.org/debian testing main"
apt-get update --assume-yes

apt-get install              \
    --target-release testing \
    --assume-yes             \
    --no-install-recommends  \
    ${testing_dependencies[*]}

# Clean up
apt-get clean
apt autoremove --assume-yes
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
