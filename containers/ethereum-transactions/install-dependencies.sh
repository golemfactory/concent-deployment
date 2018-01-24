#! /bin/bash -e

dependencies=(
    git
    python3
    python3-pip
    python3-virtualenv
    python3-setuptools
    python3-wheel
    python3-dev
    libssl-dev
    build-essential
    automake
    pkg-config
    libtool
    libffi-dev
    libgmp-dev
    libyaml-cpp-dev
    libssl-dev
    autoconf
)

apt-get --assume-yes update
apt-get --assume-yes install --no-install-recommends ${dependencies[*]}

pip3 install web3
pip3 install bitcoin

git clone                                            \
    https://github.com/ethereum/pyethereum.git       \
    /tmp/pyethereum                                  \
    --branch v2.3.0

cd /tmp/pyethereum/
python3 setup.py install


apt-get clean
rm -rf /tmp/*
