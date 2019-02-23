# concent-deployment
Scripts and configuration for Concent deployment

## GKE cluster configuration

### Storage

The `nginx-storage` pod assumes that an ext4-formatted persistent disk with name defined by the `nginx_storage_disk` variable in `var.yml` is provisioned and mounts it in read-write mode.
To provision such a disk for the development cluster use the following command:

``` bash
gcloud compute disks create --size 30GB <disk name>
```

### Creating the database

Before creating a new cluster in GKE, a PosgreSQL database and role have to be created for it.
This operation requires privileges for creating and deleting arbitrary databases in Cloud SQL.
For security reasons the role used to access the database from within the cluster should not have such wide privileges and this step needs to be performed outside of cluster deployment process.

``` bash
cd concent-deployment/cloud/
ansible-playbook create-databases.yml                              \
    --extra-vars cluster=$cluster                                  \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user
```

## Build scenarios

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
openssl req                      \
    -x509                        \
    -nodes                       \
    -sha256                      \
    -days   365                  \
    -newkey rsa:2048             \
    -keyout nginx-proxy-ssl.key  \
    -out    nginx-proxy-ssl.crt  \
    -config extensions.cnf
```

`extensions.cnf` file
```
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
x509_extensions    = x509_ext
distinguished_name = dn

[dn]
C            = <country>
ST           = <state>
O            = <organization>
OU           = <organization_unit>
CN           = <domain_name>
emailAddress = <email_address>

[x509_ext]
basicConstraints     = CA:FALSE
subjectAltName       = @alt_names
subjectKeyIdentifier = hash

[alt_names]
DNS.1 = <domain_name>
```
Replace `<country>`, `<state>`, `<organization>`, `<organization_unit>`, `<domain_name>`, `<email_address>` with actual values.

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


### Uploading secrets and access to deploy on specific gcloud environment
This is a separate step that is needed on the new server and in the case of changes in secrets

```bash
cd concent-deployment/concent-builder/
ansible-playbook install-secrets.yml                               \
    --extra-vars cluster=$cluster                                  \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user
```

All the instructions below assume that you're using local playbooks to run build and deployment commands on a new server.

Note that if you're running the playbooks themselves from within that server too, you need to add `--connection=local` to your `ansible-playbook` calls.
Otherwise Ansible will run its commands over SSH (rather than directly) using the public IP specified in `ansible_inventory`, which will likely fail because you're not supposed to have your private SSH key on the remote server you're connecting to.

### Building containers and cluster configuration
Before following these instructions, please make sure that the Concent version you're building (i.e. `concent_version` in `containers/versions.yml`) is listed in `concent_versions` dictionary in `var-concent-<cluster>.yml` file.
At any given time there can be multiple Concent versions deployed to different clusters within the same environment (e.g. `v1.8` and `v1.9` on `dev`, `v1.9` and `v2.0` on `staging`, etc.) and this dictionary contains configuration values that are not the same for all those clusters.
Without providing configuration values there you won't be able to generate Kubernetes cluster configuration or use Ansible playbooks to deploy to the cluster.

``` bash
cd concent-deployment/concent-builder/
ansible-playbook install-repositories.yml                          \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user

ansible-playbook build-test-and-push.yml                           \
    --extra-vars cluster=$cluster                                  \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user
```

### Deploying secrets
Before you can deploy containers, you need to make sure that certificates, keys and passwords used to configure those containers are available on the cluster.
Deploy them with:

``` bash
cd concent-deployment/cloud/
ansible-playbook cluster-deploy-secrets.yml                        \
    --extra-vars cluster=$cluster                                  \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user
```
This step is necessary only when deploying the cluster for the first time or when the secrets change.
Secret deployment is separate from deployment of the application specifically so that they can be performed separately, possibly from different machines.

### Deploying to the cluster

``` bash
cd concent-deployment/concent-builder/
ansible-playbook deploy.yml                                        \
    --extra-vars cluster=$cluster                                  \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user
```

### Update configuration of nginx-proxy

This step is necessary only when we move persistent disks or IP address from nginx-proxy on one cluster to another (as specified in `var-concent-<cluster>.yml` file in `concent-deployment-values`).
That's because when you update the `var` file and deploy to a new cluster, the previous cluster still has the disks or the IP attached.
Running this playbook updates the configuration of the old cluster so that the disks and IPs are released.
The new cluster will then claim them automatically.

``` bash
cd concent-deployment/concent-builder/
ansible-playbook redeploy-nginx-proxy-router.yml                   \
    --extra-vars cluster=$cluster                                  \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user
```

### Initializing or migrating the database

`concent-api` and other Django apps will try to connect a CloudSQL database configured in their settings.
Control and storage clusters have separate databases that need to be created and migrated individually.
Set `$cluster_type` to `control` or `storage` before proceeding.
These commands are meant to be executed on every cluster separately.

#### Initialization

Initialization must only be performed on a newly created cluster or if we want to clear the data and start from scratch:

``` bash
cd concent-deployment/concent-builder/
ansible-playbook job-cleanup.yml                                   \
    --extra-vars cluster=$cluster                                  \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user

ansible-playbook reset-db.yml                                      \
    --extra-vars "cluster=$cluster cluster_type=$cluster_type"     \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user
```

**WARNING**: This operation removes all the data from an existing database.

#### Migration

From time to time a Concent update may require making changes to the database schema.
This is done using Django migrations.
Migrations should be executed after containers with new version have been deployed and all the containers running the old version deleted.

``` bash
cd concent-deployment/concent-builder/
ansible-playbook job-cleanup.yml                                   \
    --extra-vars cluster=$cluster                                  \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user

ansible-playbook migrate-db.yml                                    \
    --extra-vars "cluster=$cluster cluster_type=$cluster_type"     \
    --inventory  ../../concent-deployment-values/ansible_inventory \
    --user       $user
```

It's safe to run migrations even if there are no changes - Django will detect that and simply leave the schema as is.

#### Helper script for deployment process

###### `build-and-deploy-to-dev.sh`
This script provides a streamlined way to deploy a development version of the code to the `concent-dev` cluster.
The use case could be automated because it does not require as much flexibility as the usual deployment procedure.
The `concent-dev` cluster does not hold any production data and when something goes wrong it's fine to just remove everything and start from scratch.

The `configure.yml` playbook installs the script on the build server where it can use secrets necessary to access the cluster.
Then it can be run from that server by any user.

The script deploys the code from the `dev` branch in the `concent-deployment` repository.
Version of the `concent` repository is specified in `concent_version` in `containers/versions.yml`.
To deploy any other version you must change this value in your local working copy, push the commit to the repository and update the `dev` branch to point at it.
The value can be a commit ID, tag, branch.

The script performs its job by running the Ansible playbooks listed above in the right order and with the parameters suitable for the `concent-dev` cluster.

Command-line options:
1. **database_operation**: _migrate_ (default) or _reset_.
    _migrate_ does not clear the database runs the migrations.
    _reset_ clears the database and reinitializes it.
2. **deployment_dir**: the directory to store a clone of the `concent-deployment` repository.
    `~/deployment` by default.
    This working copy should not be modified manually.
    The script will recreate it if it does not exist or update it if it does but it will fail if a checkout is not possible (e.g. because there are uncommitted changes).

### Building nginx-storage locally

Step-by-step instructions to building and running `nginx-storage` locally.


- Install dependencies:

```bash
apt-get update
apt-get install make python3 python-pip python3-yaml docker.io
pip install yasha
```


- Ensure that your user is in the `docker` group and that this group exists.
  This is necessary to be able to run docker commands without `root` privileges.
  Note that the change will not take effect until you log out of the current shell session.

```bash
sudo groupadd docker
sudo usermod --all --groups docker <user>
```


- Go to `concent-deployment` repository and run makefile to build `nginx-storage` image:

```bash
cd <path to concent deployment repository>/containers/
make nginx-storage
```


- Run nginx-storage:

```bash
docker run                         \
   --rm                            \
   --hostname nginx-storage-server \
   --network  host                 \
   --name     nginx-storage        \
   nginx-storage
```


- If everything went OK, you should now be able to reach `nginx-storage` on localhost:

```bash
curl http://localhost:8001/
```

## Concent Signing Service
In addition to Concent itself, this repository contains files necessary to build the Concent Signing Service.
`Makefile` builds a Docker container but also produces a source package that includes `Dockerfile` and all source files needed to build it.
The package can be used to build the container without having to set up `concent-deployment`.

### Building the Signing Service package
This is only needed if you want to build the package yourself.
If you have received the package and only want to build and run the docker container, you can skip this section.

1. Install dependencies needed to build containers and render configuration files from templates.

    Example for Ubuntu:

    ``` bash
    apt-get update
    apt-get install make python3 python-pip python3-yaml
    apt-get install docker.io
    pip install yasha
    ```

2. Ensure that you can start docker containers.
    It's recommended to add your user to the `docker` group (make sure that this group exists) so that you don't have to do this as root.
    Note that the change will not take effect until you log out of the current shell session.

    Example for Ubuntu:

    ``` bash
    sudo groupadd docker
    sudo usermod --all --groups docker <your user name>
    ```

3. Run make

    ```bash
    cd containers/
    make concent-signing-service-package
    ```

### Building the Signing Service from the package
1. Extract the package
2. Go to `signing_service/` directory inside the package and build the Docker image

    ``` bash
    cd signing_service/
    docker build --tag concent-signing-service:$(cat signing-service/RELEASE-VERSION) .
    docker tag                                                         \
        concent-signing-service:$(cat signing-service/RELEASE-VERSION) \
        concent-signing-service:latest
    ```

### Generating a key pair
Signing Service needs a key pair to secure its communication with Concent.
These are the same keys that are used for signing messages generated by golem-messages.
They're just base64-encoded so that they can be easily passed on the command line or in shell variables.

The public key needs to be known to Concent.
The private one must not - this is the whole point of having a separate service for signing.

When setting up a new instance of the service, you can easily generate a new pair using the `generate-ecc-key-pair.sh` script included in the Docker image:

```bash
docker run                      \
    --interactive               \
    --tty                       \
    --entrypoint /bin/bash      \
    concent-signing-service     \
    generate-ecc-key-pair.sh
```
### Running the Signing Service
To run it in a docker container with access to your local network interface, run:

```bash
docker run                                                                                                      \
    --detach                                                                                                    \
    --env         ETHEREUM_PRIVATE_KEY                                                                          \
    --env         SIGNING_SERVICE_PRIVATE_KEY                                                                   \
    --env         SENTRY_DSN                                                                                    \
    --network     host                                                                                          \
    --hostname    signing-service                                                                               \
    --name        signing-service                                                                               \
    --volume      /var/log/concent/daily_thresholds:/usr/lib/signing_service/signing-service/daily_thresholds   \
    --restart     on-failure                                                                                    \
    concent-signing-service                                                                                     \
        --concent-cluster-host                  concent.golem.network                                           \
        --concent-public-key                    85cZzVjahnRpUBwm0zlNnqTdYom1LF1P1WNShLg17cmhN2Us                \
        --concent-cluster-port                  9055                                                            \
        --ethereum-private-key-from-env                                                                         \
        --signing-service-private-key-from-env                                                                  \
        --sentry-dsn-from-env                                                                                   \
        --sentry-environment                    mainnet
```

This assumes that:
- The service can connect to a Concent cluster at `concent.golem.network:9055`.
- `85cZzVjahnRpUBwm0zlNnqTdYom1LF1P1WNShLg17cmhN2Us` is Concent's public key encoded in base64.
- There's a shell variable called `ETHEREUM_RPIVATE_KEY` and it contains base64-encoded private key of the Concent contract.
- There's a shell variable called `SIGNING_SERVICE_PRIVATE_KEY` and it contains base64-encoded private key for signing Golem Messages created by the Signing Service.
- There's a shell variable called `SENTRY_DSN` that contains the secret ID that allows submitting crash report to a [Sentry](https://sentry.io) project.
    The one given above is just an example.
    If so, you need to provide a valid DSN for the project that should receive the reports.
    Otherwise just skip the `--sentry-dsn-from-env` parameter and the `SENTRY_DSN` variable.
- `mainnet` is the name of the Sentry environment that should be included in error reports.
- `/var/log/concent/daily_thresholds/` is location in the host system where the Signing Service can create daily threshold reports.
    It must be writable by a user with UID of 999 which is the UID under which the application runs in the container.

Note that the service will crash on errors.
The host system is responsible for restarting it in that case.
If it's running in a Docker container you can easily achieve this with the `--restart on-failure` option.

### Concent Virtual Machine
The `concent-vm/` directory contains a Vagrant configuration that creates a virtual machine with Concent set up for development.
The machine has multiple purposes:
- It can be used to run and debug Concent tests in a reproducible environment.
- It serves as a reference for setting up Concent development environment.
- It can can be set up to run Golem from source.

#### Prerequisites
##### Vagrant
You need Vagrant >= 2.2.0.
Install it with your system package manager.

##### VirtualBox
The machine runs on VirtualBox.
Install it with your system package manager.

VirtualBox provides several kernel modules and requires them to be loaded before you can start any virtual machine.
These modules need to be built for your specific kernel version and rebuilt again whenever you update your kernel.
It's recommended to use [DKMS](https://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support) to do this automatically.
Most distributions provide a package named `virtualbox-dkms` or `virtualbox-host-dkms` that provides module sources and configures your system to build them.

On some systems the modules are not loaded automatically after the installation.
If you can't start a machine, try to load `vboxdrv` kernel module manually first:
```bash
sudo modprobe vboxdrv
```
These modules are loaded automatically when the system starts so you should no longer have to do this after the next reboot.

##### Vagrant plugins
Install `vagrant-vbguest` plugin:
```
vagrant plugin install vagrant-vbguest
```

#### Building the machine
`concent-vm/Vagrantfile` creates performs basic setup but does not install Concent or Golem.
It installs system packages and starts services that may be needed by either.

This step needs access to `concent-deployment` sources.
`CONCENT_DEPLOYMENT_VERSION` specifies git branch/tag/commit to use.
Sources are downloaded from Github (it does **not** copy the code from your local repository).

``` bash
cd concent-vm/
export CONCENT_DEPLOYMENT_VERSION=master
vagrant up
```

##### Installing Concent
###### Configuration
This step requires two configuration files.

`concent-vm/extra_settings.py` is a Python script that will be imported into the automatically generated `local_settings.py` in the machine.
You can use it to provide secrets or override default settings.
It can be empty if you're fine with defaults.

`concent-vm/signing-service-env.sh` is a shell script meant to be sourced immediately before starting an instance of Concent's Signing Service and can define values of environment variables used by it.
At minimum it should define the following variables:

``` bash
export ETHEREUM_PRIVATE_KEY="..."
export SIGNING_SERVICE_PRIVATE_KEY="..."
```

###### Installation
After creating the configuration, it's enough to run the following playbook:
``` bash
ansible-playbook install-concent.yml                               \
    --extra-vars  concent_version=master                           \
    --private-key .vagrant/machines/default/virtualbox/private_key \
    --user        vagrant                                          \
    --inventory   inventory
```

`concent_version` parameter determines which branch/tag/commit from the `concent` repository will be deployed in the machine.
Version listed in `containers/versions.yml` in `concent-deployment` repository is used by default.

##### Installing Golem
Golem installation does not require any extra configuration.
Just run the following playbook:
``` bash
ansible-playbook install-golem.yml                                 \
    --extra-vars  golem_version=develop                            \
    --private-key .vagrant/machines/default/virtualbox/private_key \
    --user        vagrant                                          \
    --inventory   inventory
```

`golem_version` parameter determines which branch/tag/commit from the `golem` repository will be deployed in the machine.
Version listed in `containers/versions.yml` in `concent-deployment` repository is used by default.

#### Using the machine
##### Using Vagrant
Please read the [Getting Started](https://www.vagrantup.com/intro/getting-started/) page in Vagrant docs to get familar with basic operations like starting the machine, logging into it via ssh or destroying it.

##### Helper scripts
The machine provides several scripts that automate common development tasks.
They're located in `/home/vagrant/bin/` which is in user's `PATH` so you can execute them from any location.

###### `concent-env.sh`
This is a helper script that loads a Python virtualenv with all dependencies required to run Concent and enters the directory that contains a working coy of the `concent` repository.

This script is meant to be sourced rather than executed:
```
source concent-env.sh
```

Use it when you want to be able to run scripts from the repository (start Concent, run unit tests, etc.).
All the helper scripts provided with the machine source this file automatically when needed.

###### `concent-run.sh`
This script starts Concent, including:
- A development Django server (`manage.py runserver`).
- 3 Celery worker instances attached to the right queues.
- Signing Service
- Middleman

###### `concent-migrate.sh`
Migrates the databases, preserving their content.

###### `concent-reset.sh`
This script reinitializes Concent, removing all data stored by it so that you can start from scratch:
- Destroys and recreates the databases.
- Migrates the databases.
- Empties RabbitMQ queues.
- Re-creates the superuser account.
- Restarts all the services.
- Does **not** remove blockchain data.

###### `concent-update.sh`
Updates Concent to the version (tag/branch/commit) specified in the first parameter (`master` by default):
- Fetches the latest code from git.
- Checks out the specified version.
- Destroys and recreates the virtualenv.
- Installs Concent dependencies in the virtualenv.
- Migrates the databases.

###### `concent-run-all-tests.sh`
This script run all concent tests, before execute, you must run the `concent-run.sh` script in a second console.
- Sources `concent-env.sh`.
- Starts `full-check.sh`.
- Starts `api-e2e-tests.sh`.

###### `golem-env.sh`
Similar to `concent-env.sh`.
Prepares your shell for work with the Golem working copy checked out in the machine:
- Loads the virtualenv with Golem's dependencies.
- Changes the directory to `golem`.

This script is meant to be sourced rather than executed:
```
source golem-env.sh
```

###### `golem-run-console-mode.sh`
Starts Golem without GUI.
- Sources `golem-env.sh`.
- Starts `golemapp` in console mode and passes all the command-line arguments to it.

You can use it to start Golem like this:
``` bash
golem-run-console-mode.sh \
    --accept-terms        \
    --password $password
```

`$password` needs to contain your Golem password.

You can see all the available `golemapp` options by running:

``` bash
golem-run-console-mode.sh --help
```

###### `golem-run-concent-integration-tests.sh`
Starts Golem integration tests for concent.
- Sources `golem-env.sh`.
- Starts `pytest` and passes all the command-line arguments to it.

For example:
```bash
golem-run-concent-integration-tests.sh              \
    scripts/concent_acceptance_tests/force_accept   \
    --maxfail=1                                     \
    -vs                                             \
    --lf
```

##### What's inside the machine
Here's some extra information you should be aware of when using the machine:
- The following services are automatically started inside the machine when the it boots:
    - Docker
    - PostgreSQL (accepts connections from within the machine without a password)
    - RabbitMQ (runs in a Docker container)
    - Geth (runs in a Docker container)
    - nginx (configured to act as `nginx-storage`, built from `concent-deployment`)
- The initialization playbook automatically creates PostgreSQL databases required by Concent
- Concent, Signing Service and Golem do not start automatically.
    Since you may want to run only one or the other, you need to start them using the helper scripts listed above.
