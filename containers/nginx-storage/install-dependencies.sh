#!/bin/sh -e

apk update
apk add            \
    --no-cache     \
    git            \
    curl           \
    perl           \
    zlib-dev

# Lua library that provides functions for file manipulation.
# We need it mainly for mkdir().
opm get spacewander/luafilesystem

# Create .so symlink for libcrypto.so manually.
# In normal circumstances the link would be created by ldconfig,
# but in Alpine Linux ldconfig is non-functional.
ln -s /usr/lib/libcrypto.so.41 /usr/lib/libcrypto.so

# Github repository with nginx-big-upload module
git clone                                            \
    https://github.com/pgaertig/nginx-big-upload.git \
    /opt/nginx-big-upload                            \
    --branch v1.4.0                                  \
    --depth  1

rm -rf /opt/nginx-big-upload/.git

# Lua libs focusing on input data handling, functional programming and OS path management.
/usr/local/openresty/luajit/bin/luarocks install penlight

rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
