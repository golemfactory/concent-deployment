#! /bin/bash -e

source repositories.sh
export repositories

list_of_directories=$(ls /var/git-mirror/)
for directory in "${list_of_directories[@]}"; do
    if [[ ! " ${!repositories[@]} " =~ " ${directory} " ]]; then
        rm -rf /var/git-mirror/$directory
        echo jestem
    fi
done
for repository in "${!repositories[@]}"; do
    repository_path="/var/git-mirror/$repository/"
    if [ ! -d $repository_path ]; then
        git clone --mirror "${repositories[$repository]}" "$repository_path"
    else
        git fetch --prune
    fi
done
