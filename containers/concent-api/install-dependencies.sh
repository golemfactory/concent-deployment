#!/bin/bash -e

# Update package lists for Debian and install dependencies
dependencies=(
    python3-pip
    python3-virtualenv
    virtualenv

    # Required by psycopg2 python package (PostgreSQL support)
    libpq-dev

    # Packages needed to build python extensions, dependencies of golem-messages in particular
    gcc
    libssl1.0.2
    libssl1.0-dev
    python3-dev
    git
    wget
    build-essential
    zlib1g-dev
)
apt-get --assume-yes update
apt-get --assume-yes install --no-install-recommends ${dependencies[*]}

# Install python 3.6
wget https://www.python.org/ftp/python/3.6.0/Python-3.6.0.tgz
tar xvf Python-3.6.0.tgz
cd Python-3.6.0
./configure --enable-optimizations
make -j8
make altinstall

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
