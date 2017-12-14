FROM openresty/openresty:alpine-fat

COPY install-dependencies.sh /tmp/
RUN /tmp/install-dependencies.sh

COPY table_utils.lua /usr/local/openresty/lualib/
