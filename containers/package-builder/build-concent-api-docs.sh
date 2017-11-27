#!/bin/bash -e

concent_dir=$(realpath "$1")
package_builder_dir=$(realpath "$2")
build_dir=$(realpath "$3")
output_dir=$(realpath "$4")

mkdir --parents "$build_dir/concent-api-docs/"
cp --recursive "$concent_dir/docs" "$build_dir/concent-api-docs"

cd "$build_dir/concent-api-docs/docs/"

virtualenv --python python3 "$build_dir/docs-virtualenv/"
source "$build_dir/docs-virtualenv/bin/activate"
pip install -r "requirements.txt"

make html

tar                                                \
    --create                                       \
    --verbose                                      \
    --file="$output_dir/concent-api-docs.tar"      \
    --directory="build/"                           \
    html/
