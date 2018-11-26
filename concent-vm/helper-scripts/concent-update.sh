#!/bin/bash -e

branch_name="$1"
if [ -z "$branch_name" ]; then
    echo "Please specify the name of branch"
    exit 1
fi

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
