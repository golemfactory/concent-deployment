#!/bin/bash -e

trap "kill 0" SIGINT


# Running the commands in $() allows our trap to kill them all on exit
result=$(
    golem-run-console-mode.sh $@ & \
    cd ~/golem_electron/;          \
    npm run start:app &            \
    npm run start &                \
)
