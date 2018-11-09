#! /bin/bash -e

source /usr/local/lib/repositories.sh
export repositories

list_of_directories=(
    $(ls /var/git-mirror/)
)

# Check list of directories in `/var/git-mirror/` path with repositories list in the `repositories.sh` file.
for directory in "${list_of_directories[@]}"; do
    if [[ ! " ${!repositories[@]} " =~ " ${directory} " ]]; then
        rm -rf "/var/git-mirror/$directory/"
    fi
done

# Check if repositories from the `repositories.sh` file exist in `/var/git-mirror` path
# and clone or update them.
for repository in "${!repositories[@]}"; do
    repository_path="/var/git-mirror/$repository/"
    if [ ! -d $repository_path ]; then
        git clone --mirror "${repositories[$repository]}" "$repository_path"
    else
        cd "$repository_path"
        git fetch origin --prune
    fi
done
