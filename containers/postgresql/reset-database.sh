#!/bin/bash -e

db_host=$1
db_name=$2
db_user=$3

if [[ $db_user == "postgres" ]]; then
    echo "Do not use the built-in PostgreSQL admin account to run your application!"
    exit 1
fi

database_query="SELECT DISTINCT schema_name
                FROM information_schema.schemata
                WHERE schema_owner = '"$db_user"';"

schema_names="$(
    psql                                 \
        "$db_name"                       \
        --host "$db_host"                \
        --username $db_user              \
        --tuples-only                    \
        --command "$database_query"      \
)"
query_success=$?

if [[ $query_success != 0 ]]; then
    exit 1
fi


schema_names_stripped=${schema_names// }

# Create an array containing lines from $schema_names_stripped.
readarray -t schema_names  <<< "$schema_names_stripped"

# Create variable which is contain sql commands for dropping all schemas.
for schema_name in ${schema_names[@]}; do
    drop_schema_commands+=" DROP SCHEMA $schema_name CASCADE;"
done

psql --variable ON_ERROR_STOP=1 $db_name --host $db_host --username $db_user <<EOF
    $drop_schema_commands
    CREATE SCHEMA public;
EOF
