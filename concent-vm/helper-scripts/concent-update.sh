#!/bin/bash -e

DEFAULT_BRANCH=master

branch_name="${1:-$DEFAULT_BRANCH}"

cd ~/concent/concent_api/

# Fetch new code and checkout specific branch
git fetch origin --prune
git checkout origin/$branch_name

# Delete and recreate virtualenv
rm -rf ~/virtualenv/

virtualenv --python python3 ~/virtualenv/
source ~/virtualenv/bin/activate

cd ~/concent/concent_api
python -m pip install --requirement "requirements.lock"

cd ~/concent/
python -m pip install --requirement "requirements-development.txt"

# Migrate databases
concent-migrate.sh
