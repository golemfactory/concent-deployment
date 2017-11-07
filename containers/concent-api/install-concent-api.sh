#!/bin/bash -e

# Create virtualenv and Django app's dependencies
virtualenv --python python3 "/srv/http/virtualenv"
source "/srv/http/virtualenv/bin/activate"
pip install --upgrade pip
pip install --requirement "/srv/http/concent_api/requirements.txt"
pip install gunicorn
