# concent-deployment
Scripts and configuration for Concent deployment

## GKE cluster configuration

### Storage

The `nginx-storage` pod assumes that an ext4-formatted persistent disk with name defined by the `nginx_storage_disk` variable in `var.yml` is provisioned and mounts it in read-write mode.
To provision such a disk for the development cluster use the following command:

``` bash
gcloud compute disks create --size 30GB <disk name>
```

## Deployment scenarios

Scripts in this repository allow you to build containers and cluster configuration in three different scanarios. Each one has its own requirements:

- **Build on your local machine.**
    To do this you need to run Linux and install all the packages required to build and deploy containers.
    You build containers by running Makefiles and deploy with shell scripts.
    This mode is meant solely for deploying to the test cluster in development.
- **Build inside the `concent-builder-vm` virtual machine.**
    In this scenario all you need is Vagrant and VirtualBox.
    You use Ansible to configure the machine and then run playbooks that take care of executing all build and deployment steps.
    This mode is meant for development and for testing configuration changes meant for the `concent-builder` server itself.
- **Build on the remote `concent-builder` server.**
    In this senario you run the Ansible playbooks on a remote machine.
    You obviously need access that machine to do this.
    This is the recommended way to deploy in production.

## Deployment

### Cloning the repositories

In every scenario you need local copies of `concent-deployment` and `concent-deployment-values` repositories:

``` bash
git clone git@github.com:golemfactory/concent-deployment.git
git clone git@github.com:golemfactory/concent-deployment-values.git

ln --symbolic ../../concent-deployment-values/var.yml          concent-deployment/kubernetes/var.yml
ln --symbolic ../../concent-deployment-values/var-$cluster.yml concent-deployment/kubernetes/var-$cluster.yml
```

The above assumes that the `$cluster` shell variable is set to the name of the cluster you're deploying to and that `concent-deployment-values` contains the configuration for that cluster.

### Secrets

Passwords and keys required for deployment are not stored in the repository.
To deploy you need to get access to them and put them in the following locations:

- `concent-secrets/$cluster/concent-builder-service-private-key.json`
- `concent-secrets/$cluster/secrets.py`
- `concent-secrets/$cluster/var-secret.yml`

#### SSL certificates

The nginx instances need certificates and private keys to be able to serve HTTPS traffic.
Put them in the following locations:

- `concent-secrets/$cluster/nginx-proxy-ssl.crt`
- `concent-secrets/$cluster/nginx-proxy-ssl.key`
- `concent-secrets/$cluster/nginx-storage-ssl.crt`
- `concent-secrets/$cluster/nginx-storage-ssl.key`

#### Generating self-signed certificates

It's best if your certificates are signed by a Certificate Authority (CA) because then it's possible for the client to verify their authenticity without having to know the public key ahead of time.
This is not required though.
You can generate and use a self-signed certificate.

Here's an example command that generates a 2048-bit RSA certificate valid for a year:

``` bash
openssl req                     \
    -x509                       \
    -nodes                      \
    -days   365                 \
    -newkey rsa:2048            \
    -keyout nginx-proxy-ssl.key \
    -out    nginx-proxy-ssl.crt
```

### Setting up the `concent-builder-vm` virtual machine.

Do this if you want to use the virtual machine for deployment.

- Install Vagrant, VirtualBox and Ansible using your system package manager.
- Create and configure the virtual machine:

    ``` bash
    cd concent-deployment/concent-builder-vm
    vagrant up
    ```

    This will run the `configure.yml` playbook for you.

### Configuring `concent-builder` machine

Do this if you want to use the remote server for building and deploying.

- Run the `configure.yml` playbook.

    ``` bash
    cd concent-deployment/concent-builder/
    ansible-playbook configure.yml                                    \
        --inventory ../../concent-deployment-values/ansible_inventory \
        --user      $user
    ```

    Where the `$user` shell variable contains the name of your shell account on the remote machine.

All the instructions below assume that you're using the remote server.

### Uploading secrets, building containers and cluster configuration

``` bash
cd concent-deployment/concent-builder/
ansible-playbook install-repositories.yml                          \
    --extra-vars cluster=$cluster                                  \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user

ansible-playbook build.yml                                         \
    --extra-vars cluster=$cluster                                  \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user
```

### Creating the database

`concent-api` and other Django apps will try to connect a CloudSQL database configured in their settings.
Control and storage clusters have separate databases that need to be created and migrated individually.
Set `$cluster_type` to `control` or `storage` before proceeding. These commands are meant to be executed on every cluster separately.

``` bash
cd concent-deployment/concent-builder/
ansible-playbook job-cleanup.yml                                   \
    --extra-vars cluster=$cluster                                  \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user

ansible-playbook create-db.yml                                     \
    --extra-vars "cluster=$cluster cluster_type=$cluster_type"     \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user

ansible-playbook migrate-db.yml                                    \
    --extra-vars "cluster=$cluster cluster_type=$cluster_type"     \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user
```

### Deploying to the cluster

``` bash
cd concent-deployment/concent-builder/
ansible-playbook deploy.yml                                        \
    --extra-vars cluster=$cluster                                  \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user
```
