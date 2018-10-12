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

All the instructions below assume that you're using the remote server.

### Building containers and cluster configuration

``` bash
cd concent-deployment/concent-builder/
ansible-playbook install-repositories.yml                          \
    --extra-vars cluster=$cluster                                  \
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

### Running the Signing Service
To run it in a docker container with access to your local network interface, run:

```bash
docker run                                                  \
    --detach                                                \
    --env         ETHEREUM_PRIVATE_KEY                      \
    --env         SIGNING_SERVICE_PRIVATE_KEY               \
    --env         SENTRY_DSN                                \
    --network     host                                      \
    --hostname    signing-service                           \
    --name        signing-service                           \
    --restart     on-failure                                \
    concent-signing-service                                 \
        concent.golem.network                               \
        85cZzVjahnRpUBwm0zlNnqTdYom1LF1P1WNShLg17cmhN2Us    \
        --concent-cluster-port                  9055        \
        --ethereum-private-key-from-env                     \
        --signing-service-private-key-from-env              \
        --sentry-dsn-from-env                               \
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

Note that the service will crash on errors.
The host system is responsible for restarting it in that case.
If it's running in a Docker container you can easily achieve this with the `--restart on-failure` option.
