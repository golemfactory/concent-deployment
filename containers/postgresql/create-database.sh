#!/bin/bash -e

db_host=$1
db_name=$2
db_user=$3

if [[ $db_user == "postgres" ]]; then
    echo "Do not use the built-in PostgreSQL admin account to run your application!"
    exit 1
fi

database_query="SELECT 1 FROM pg_database WHERE datname = '"$db_name"'"
database_count=$(psql --host "$db_host" --username postgres --tuples-only --command "$database_query")

database_count_stripped=${database_count// }
if [[ $database_count_stripped == 1 ]]; then
    echo READY.
    exit 0
fi


user_query="SELECT 1 FROM pg_roles WHERE rolname='"$db_user"'"
user_count=$(psql --host "$db_host" --username postgres --tuples-only --command "$user_query")

user_count_stripped=${user_count// }
if [[ $user_count_stripped == 1 ]]; then
    echo READY.
    exit 0
fi

psql --host $db_host --username postgres <<EOF
    CREATE USER $db_user PASSWORD '$DB_USER_PASSWORD';
    CREATE DATABASE $db_name;
    GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;
EOF
