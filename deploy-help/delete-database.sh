#! /bin/bash -e

cluster_name=$1

# Confirm executing script
read -p "Warning must execute after deploy.sh script. Are you sure about execute this script? It's destroy database[y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

    playbooks=(
        job-cleanup.yml
        delete-db.yml
        create-db.yml
        migrate-db.yml
    )


    cd /home/builder/build/concent-dev/concent-deployment/kubernetes/build/; ./delete-services.sh

    for playbook in "${playbooks[@]}"; do
        cd ~/deployment/concent-deployment/concent-builder/; ansible-playbook $playbook --extra-vars "cluster=concent-dev cluster_type=$cluster_name" -i ../../inventory
        sleep 40
    done

    cd /home/builder/build/concent-dev/concent-deployment/kubernetes/build/; ./create-services.sh

fi
