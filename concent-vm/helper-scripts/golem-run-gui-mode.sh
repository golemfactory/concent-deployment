#! /bin/bash -e

trap "kill 0" SIGINT

golem_run_gui_command="$(
    golem-run-console-mode.sh $@ &    \
    cd ~/golem_electron/;             \
    npm run start:app &               \
    npm run start:mainnet &           \
)"


$golem_run_gui_command
