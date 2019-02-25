#!/bin/bash -e

trap "kill 0" SIGINT

# This is the display number of the X server that starts by default in our virtual machine.
# It's not universal and may not work if this script in executed in a different environment.
export DISPLAY=:0.0

# Running the commands in $() allows our trap to kill them all on exit
result=$(
    cd ~/golem_electron/; \
    npm run start:app &   \
    npm run start &       \
)
