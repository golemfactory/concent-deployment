#!/bin/bash -e

# Confirm executing script
read -n 1 -r -p "Are you sure you want to remove all databases, queue content and any other content created by the application (except blockchain data)? [y/N]"
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    database_names=(
        concent_api
        storage
    )

    # Delete and recreate databases
    for db_name in "${database_names[@]}"; do
        psql --host localhost --username postgres <<-EOF
            DROP DATABASE IF EXISTS $db_name;
            CREATE DATABASE $db_name;
EOF
    done

    # Migrate databases
    concent-migrate.sh

    # Create superuser account
    python_command="from django.contrib.auth.models import User;"
    python_command="$python_command User.objects.create_superuser('admin', 'admin@example.com', 'password')"

    (
        source concent-env.sh
        cd concent_api/
        echo "$python_command" | python manage.py shell
    )
    # Restart RabbitMQ inside the docker container.
    # This removes all data from the management database, such as configured users and vhosts, and deletes all persistent messages.
    docker exec                      \
        rabbitmq                     \
        sh -c "
            rabbitmqctl stop_app &&
            rabbitmqctl reset &&
            rabbitmqctl start_app
        "

    # Restart all service
    sudo systemctl restart postgresql
    sudo systemctl restart nginx-storage
else
    echo "Operation canceled"
fi
