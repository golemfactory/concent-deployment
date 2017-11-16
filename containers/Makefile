VERSION := 1.0.0
NGINX_PROXY_SOURCE :=               \
    build/nginx-proxy/Dockerfile    \
    build/nginx-proxy/index.html    \

CONCENT_API_SOURCE :=                           \
    build/concent-api/install-concent-api.sh    \
    build/concent-api/install-dependencies.sh   \
    build/concent-api/Dockerfile                \
    build/concent-api/concent-api-manage.sh     \
    build/concent-api/run-gunicorn.sh           \
    build/concent-api/local_settings.py

ifndef CONCENT_DIR
	CONCENT_DIR:= $(abspath ../../concent)
endif
$(info CONCENT_DIR=$(CONCENT_DIR))

all: build/ nginx-proxy concent-api

nginx-proxy: $(NGINX_PROXY_SOURCE)
	docker build -t nginx-proxy:$(VERSION) build/nginx-proxy/
	docker tag nginx-proxy:$(VERSION) nginx-proxy:latest

concent-api: $(CONCENT_API_SOURCE) build/concent-api/concent-api.tar
	docker build -t concent-api:$(VERSION) build/concent-api/
	docker tag concent-api:$(VERSION) concent-api:latest

docker-clean: nginx-proxy-clean concent-api-clean

nginx-proxy-clean:
	docker rmi nginx-proxy:$(VERSION) --force

concent-api-clean:
	docker rmi concent-api:$(VERSION) --force


build/concent-api/concent-api.tar: $(CONCENT_DIR)
	mkdir --parents $(dir $@)
	package-builder/build-concent-api.sh "$(CONCENT_DIR)" "build/concent-api"


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


.PHONY: all nginx-proxy docker-clean nginx-proxy-clean clean concent-api concent-api-clean
