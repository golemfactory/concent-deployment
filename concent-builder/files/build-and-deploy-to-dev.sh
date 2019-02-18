#! /bin/bash -e

export ANSIBLE_STDOUT_CALLBACK=debug
DEFAULT_DATABASE_OPERATION=migrate
DEFAULT_DEPLOYMENT_DIR=~/deployment
database_operation="${1:-$DEFAULT_DATABASE_OPERATION}"
deployment_dir="${2:-$DEFAULT_DEPLOYMENT_DIR}"

function ansible_command {
    echo "playbook: '$1', cluster: '$2', cluster type: '$3'"
    file="$1"
    cluster_name="$2"
    cluster_type="$3"
    ansible-playbook                                                      \
        $file                                                             \
        --connection local                                                \
        --extra-vars "cluster=$cluster_name cluster_type=$cluster_type"   \
        --inventory ../../concent-deployment-values/ansible_inventory
}

declare -A repositories

repositories=(
    ["concent-deployment"]="https://github.com/golemfactory/concent-deployment.git"
    ["concent-deployment-values"]="https://github.com/golemfactory/concent-deployment-values.git"
)

if [ ! -d $deployment_dir ]; then
    mkdir $deployment_dir/
fi
for repository in "${!repositories[@]}"; do
    repository_path="$deployment_dir/$repository/"
    if [ ! -d $repository_path ]; then
        git clone "${repositories[$repository]}" "$repository_path"
    else
        cd "$repository_path"
        git fetch origin --prune
    fi
done

(
    for repository in "${!repositories[@]}"; do
        cd $deployment_dir/$repository/
        git checkout origin/dev
    done
)

if [[ "$database_operation" == "migrate" ]]; then
    database_operation_playbook=migrate-db.yml
elif [[ "$database_operation" == "reset" ]]; then
    database_operation_playbook=reset-db.yml
else
    echo 'Invalid database operation $database_operation. Available operations: migrate, reset'
    exit 1
fi

(
    cd $deployment_dir/concent-deployment/concent-builder/

    databases=(
        control
        storage
    )
    playbooks=(
        install-repositories.yml
        build-test-and-push.yml
        job-cleanup.yml
    )

    for playbook in "${playbooks[@]}"; do
        ansible_command $playbook concent-dev
    done
    for database in "${databases[@]}"; do
        ansible_command $database_operation_playbook concent-dev $database
    done

    ansible_command deploy.yml concent-dev
)
