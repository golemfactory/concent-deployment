FROM openresty/openresty:1.13.6.1-1-alpine-fat

COPY install-dependencies.sh /tmp/
RUN /tmp/install-dependencies.sh

COPY table_utils.lua /usr/local/openresty/lualib/
