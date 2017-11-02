VERSION := 1.0.0
NGINX_PROXY_SOURCE :=         \
    nginx-proxy/Dockerfile    \
    nginx-proxy/index.html    \
    nginx-proxy/default.conf

all: nginx-proxy

nginx-proxy: nginx-proxy-source
	docker build -t nginx-proxy:$(VERSION) nginx-proxy/
	docker tag nginx-proxy:$(VERSION) nginx-proxy:latest


docker-clean: nginx-proxy-clean

nginx-proxy-clean:
	docker rmi nginx-proxy:$(VERSION) --force

.PHONY: all nginx-proxy docker-clean nginx-proxy-clean nginx-proxy-source

nginx-proxy-source: $(NGINX_PROXY_SOURCE)
