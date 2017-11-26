#!/bin/bash -e

virtualenv_dir=/srv/http/virtualenv

# Create virtualenv and Django app's dependencies
virtualenv --python python3 "$virtualenv_dir"
source "$virtualenv_dir/bin/activate"
pip install --upgrade pip
pip install --requirement "/srv/http/concent_api/requirements.txt"
pip install gunicorn
