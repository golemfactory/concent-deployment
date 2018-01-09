#!/bin/bash -e

concent_dir=$(realpath "$1")
package_builder_dir=$(realpath "$2")
build_dir=$(realpath "$3")
output_dir=$(realpath "$4")
python_version=3.5
libcrypto_path=/usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.2

mkdir --parents "$build_dir/concent-api-assets/"
cp --recursive "$concent_dir/concent_api" "$build_dir/concent-api-assets"

cd "$build_dir/concent-api-assets/concent_api/"

virtualenv --python python3 "$build_dir/virtualenv/"
source "$build_dir/virtualenv/bin/activate"
pip install -r "requirements.lock"

cp "$package_builder_dir/minimal_settings.py" "concent_api/settings/local_settings.py"

if [ ! -f "$libcrypto_path" ]; then
    echo ERROR: $libcrypto_path does not exist. Is OpenSSL 1.0 installed?
    exit 1
fi

# pyelliptic is unmaintained and does not work with OpenSSL 1.1.
# We have the 1.0 version of libssl installed but we must patch pyelliptic to use it.
sed                                                                                          \
    "s%ctypes.util.find_library('crypto')%'$libcrypto_path'%"                                \
    --in-place $build_dir/virtualenv/lib/python$python_version/site-packages/pyelliptic/openssl.py


./manage.py collectstatic --noinput

tar                                             \
    --create                                    \
    --verbose                                   \
    --file="$output_dir/concent-api-assets.tar" \
    static-root/
