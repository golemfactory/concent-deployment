#!/bin/bash -e

virtualenv_dir=/srv/http/virtualenv
python_version=3.5

# Create virtualenv and Django app's dependencies
virtualenv --python python3 "$virtualenv_dir"
source "$virtualenv_dir/bin/activate"
pip install --upgrade pip
pip install --requirement "/srv/http/concent_api/requirements.lock"
pip install gunicorn

# pyelliptic is unmaintained and does not work with OpenSSL 1.1.
# We have the 1.0 version of libssl installed but we must patch pyelliptic to use it.
sed                                                                                          \
    "s%ctypes.util.find_library('crypto')%'/usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.2'%"   \
    --in-place $virtualenv_dir/lib/python$python_version/site-packages/pyelliptic/openssl.py
