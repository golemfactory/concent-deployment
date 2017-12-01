# concent-deployment
Scripts and configuration for Concent deployment

## Deploying to the build server

ansible-playbook configure.yml            --inventory ../../concent-deployment-values/ansible_inventory --user <username>
ansible-playbook install-repositories.yml --inventory ../../concent-deployment-values/ansible_inventory --user <username>
ansible-playbook build.yml                --inventory ../../concent-deployment-values/ansible_inventory --user <username>
ansible-playbook deploy.yml               --inventory ../../concent-deployment-values/ansible_inventory --user <username>
ansible-playbook job-cleanup.yml          --inventory ../../concent-deployment-values/ansible_inventory --user <username>
ansible-playbook migrate-db.yml           --inventory ../../concent-deployment-values/ansible_inventory --user <username>
