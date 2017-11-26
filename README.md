# concent-deployment
Scripts and configuration for Concent deployment

## Deploying to the build server

ansible-playbook configure.yml            --inventory ../../concent-deployment-values/ansible_inventory --user <username>
ansible-playbook install-repositories.yml --inventory ../../concent-deployment-values/ansible_inventory --user <username>
ansible-playbook build.yml                --inventory ../../concent-deployment-values/ansible_inventory --user <username>
ansible-playbook deploy.yml               --inventory ../../concent-deployment-values/ansible_inventory --user <username>
ansible-playbook job-cleanup.yml          --inventory ../../concent-deployment-values/ansible_inventory --user <username>
ansible-playbook migrate-db.yml           --inventory ../../concent-deployment-values/ansible_inventory --user <username>

## Configuration

### Secrets

#### `concent-secrets/secrets.py`

``` python
SECRET_KEY        = "<long random string>"
DATABASE_PASSWORD = "<unencrypted password of a database role>"
```

#### `concent-secrets/var-secret.yml`

``` yaml
database_password: <password for the admin role on the database server>
user_db_password:  <base64-encoded password for the database role used by django>
```
