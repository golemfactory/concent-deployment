#!/bin/bash -e

MINIMAL_FREE_SPACE_IN_GB=15
# Variable that control deleting files older than specified value.
MAXIMUM_DAYS=30
# Variable that control lower limit for deleting files older than specified value,
# when minimal free space on disk is not available after deleting files
# older than the $MAXIMUM_DAYS value, files older than $MAXIMUM_DAYS-1 value are deleted
# up to the $MINIMUM_DAYS values.
MINIMUM_DAYS=15

DIRECTORIES=(
    /srv/storage/blender/result/
    '/srv/storage/blender/source/'
    /srv/storage/blender/verifier-output/
)

# function that deletes files older than `x` days, specified in the `days` argument
function delete_old_files {
    days="$1"
    for directory in ${DIRECTORIES[@]}; do
        find $directory          \
            -type f              \
            -mtime +$days        \
            -delete
    done
}

# function that deletes empty directories older than 7 days
function delete_empty_directories {
    for directory in ${DIRECTORIES[@]}; do
        find $directory                   \
            -mindepth 1                   \
            -type d                       \
            -mtime +7                     \
            -exec rmdir {} 2>/dev/null \;
    done
}

function check_free_space {
    local free_space="$(df | grep '/srv/storage' | awk '{ print $4; }')"
    if [ -z "$free_space" ]; then
        echo "[crond][error][disk cleanup]: There is a problem with checking free space on disk. Please check if mount point \"/srv/storage/\" exist."
        exit 1
    fi
    # Convert kilobyte to gigabyte
    let free_space=$free_space/1048576
    echo $free_space
}

for directory in ${DIRECTORIES[@]}; do
    if [ ! -d "$directory" ]; then
        echo "[crond][error][disk cleanup]: Please check if the \"$directory\" directory exist."
        exit 1
    fi
done

available_free_space=$(check_free_space)
delete_old_files $MAXIMUM_DAYS

let CURRENT_NUMBER_OF_DAYS_TO_DELETE=$MAXIMUM_DAYS-1
while (( $MINIMAL_FREE_SPACE_IN_GB > $available_free_space ))
do
    if [[ $CURRENT_NUMBER_OF_DAYS_TO_DELETE > $MINIMUM_DAYS ]]; then
        delete_old_files "$CURRENT_NUMBER_OF_DAYS_TO_DELETE"
        let CURRENT_NUMBER_OF_DAYS_TO_DELETE--
    else
        delete_empty_directories
        echo "[crond][error][disk cleanup]: Please investigate storage manually. The disk has low free space and doesn't have old files, consider bigger disk."
        exit 1
    fi
    available_free_space=$(check_free_space)
done

delete_empty_directories
echo "[crond][info][disk cleanup]: The old files have been succesfully deleted."
