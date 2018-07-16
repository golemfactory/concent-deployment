#! /bin/bash -e

cd ~; mkdir deployment

git clone https://github.com/golemfactory/concent-deployment.git ~/deployment/concent-deployment; cd ~/deployment/concent-deployment/; git fetch origin --prune

git clone https://github.com/golemfactory/concent-deployment-values.git ~/deployment/concent-deployment-values/; cd ~/deployment/concent-deployment-values/; git fetch origin --prune; git checkout origin/dev

cd ~/deployment/; cp -R /var/concent-data/concent-secrets/ ~/deployment/concent-secrets/

cd ~/deployment/concent-deployment/kubernetes/; ln -s ~/deployment/concent-deployment-values/var.yml var.yml; ln -s ~/deployment/concent-deployment-values/var-concent-dev.yml var-concent-dev.yml

cd ~/deployment/; echo "concent-builder ansible_connection=local" > inventory; cd concent-deployment/; git checkout origin/dev

echo "export ANSIBLE_STDOUT_CALLBACK=debug" >> ~/.bashrc
