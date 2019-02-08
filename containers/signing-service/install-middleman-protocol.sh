#!/bin/bash -e

virtualenv_dir=/usr/lib/signing_service/virtualenv
middleman_protocol_dir=/usr/lib/signing_service/middleman_protocol/
source "$virtualenv_dir/bin/activate"

cd "$middleman_protocol_dir"
# The `python setup.py install_lib` command is used rather than `python setup.py install` command,
# because its installs only libs and doesn't create unnecessary files like `.egg-info` package etc.
python setup.py install_lib
