#!/bin/bash -e

virtualenv_dir=/srv/http/virtualenv
middleman_protocol_dir=/srv/http/middleman_protocol/
source "$virtualenv_dir/bin/activate"

cd "$middleman_protocol_dir"
# The `python setup.py install_lib` command is used rather than `python setup.py install` command,
# because its installs only libs and doesn't create unnecessary files like `.egg-info` package etc.
python setup.py install_lib

