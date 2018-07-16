#! /bin/bash -e


cd ~/deployment/concent-deployment; git fetch origin --prune; git checkout origin/dev; cd concent-builder/;

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
    ansible-playbook $playbook --extra-vars cluster=concent-dev -i ../../inventory
done

for database in "${databases[@]}"; do
    ansible-playbook migrate-db.yml --extra-vars "cluster=concent-dev cluster_type=$database" -i ../../inventory
    sleep 40
    ansible-playbook job-cleanup.yml --extra-vars cluster=concent-dev -i ../../inventory
done

ansible-playbook deploy.yml --extra-vars cluster=concent-dev -i ../../inventory
