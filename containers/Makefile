VERSION := 1.0.0
NGINX_PROXY_SOURCE :=               \
    build/nginx-proxy/Dockerfile    \
    build/nginx-proxy/index.html    \

all: nginx-proxy

nginx-proxy: nginx-proxy-source
	docker build -t nginx-proxy:$(VERSION) build/nginx-proxy/
	docker tag nginx-proxy:$(VERSION) nginx-proxy:latest


docker-clean: nginx-proxy-clean

nginx-proxy-clean:
	docker rmi nginx-proxy:$(VERSION) --force


nginx-proxy-source: build/ $(NGINX_PROXY_SOURCE)

build/:
	mkdir --parents "$@"

# Static files
build/%: %
	cp --archive --parents "$<" build/

# Templates
build/%: %.j2 config.yml
	mkdir --parents $(dir $@)
	yasha --variables config.yml "$<" --output "$@"

	# Copy file permissions from the source file
	chown --reference="$<" "$@"
	chmod --reference="$<" "$@"

clean:
	rm -rf build/

.PHONY: all nginx-proxy docker-clean nginx-proxy-clean nginx-proxy-source clean
