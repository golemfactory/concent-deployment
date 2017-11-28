#!/bin/bash -e

db_host=$1
db_name=$2
db_user=$3

if [[ $db_user == "postgres" ]]; then
    echo "User postgres must not be deleted"
    exit 1
fi

database_query="SELECT 1 FROM pg_database WHERE datname = '"$db_name"'"
database_count=$(psql --host "$db_host" --username postgres --tuples-only --command "$database_query")

database_count_stripped=${database_count// }
if [[ $database_count_stripped != 1 ]]; then
    echo "Database "\'$db_name\'" does not exist."
    exit 1
fi

user_query="SELECT 1 FROM pg_roles WHERE rolname='"$db_user"'"
user_count=$(psql --host "$db_host" --username postgres --tuples-only --command "$user_query")

user_count_stripped=${user_count// }
if [[ $user_count_stripped != 1 ]]; then
    echo "User "\'$db_user\'" does not exist."
    exit 1
fi

psql --host $db_host --username postgres <<EOF
    DROP DATABASE $db_name;
    DROP USER $db_user;
EOF
