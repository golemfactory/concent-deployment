NGINX_PROXY_SOURCE :=               \
    build/nginx-proxy/Dockerfile    \
    build/nginx-proxy/index.html    \

POSTGRESQL_SOURCE :=                          \
    build/postgresql/Dockerfile               \
    build/postgresql/delete-database.sh       \
    build/postgresql/create-database.sh

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

ifndef IMAGE_VERSION
    IMAGE_VERSION := $(shell git describe --always)
endif
$(info IMAGE_VERSION=$(IMAGE_VERSION))

ifndef IMAGE_PREFIX
    IMAGE_PREFIX :=
endif
$(info IMAGE_PREFIX=$(IMAGE_PREFIX))


all: build/ nginx-proxy concent-api postgresql

nginx-proxy: $(NGINX_PROXY_SOURCE) build/nginx-proxy/concent-api-assets.tar build/nginx-proxy/concent-api-docs.tar
	docker build -t $(IMAGE_PREFIX)nginx-proxy:$(IMAGE_VERSION) build/nginx-proxy/
	docker tag $(IMAGE_PREFIX)nginx-proxy:$(IMAGE_VERSION) $(IMAGE_PREFIX)nginx-proxy:latest

postgresql: $(POSTGRESQL_SOURCE)
	docker build -t $(IMAGE_PREFIX)postgresql:$(IMAGE_VERSION) build/postgresql/
	docker tag $(IMAGE_PREFIX)postgresql:$(IMAGE_VERSION) $(IMAGE_PREFIX)postgresql:latest

concent-api: $(CONCENT_API_SOURCE) build/concent-api/concent-api.tar
	docker build -t $(IMAGE_PREFIX)concent-api:$(IMAGE_VERSION) build/concent-api/
	docker tag $(IMAGE_PREFIX)concent-api:$(IMAGE_VERSION) $(IMAGE_PREFIX)concent-api:latest

docker-clean: nginx-proxy-clean concent-api-clean postgresql-clean

nginx-proxy-clean:
	docker rmi $(IMAGE_PREFIX)nginx-proxy:$(IMAGE_VERSION) --force

postgresql-clean:
	docker rmi $(IMAGE_PREFIX)postgresql:$(IMAGE_VERSION) --force

concent-api-clean:
	docker rmi $(IMAGE_PREFIX)concent-api:$(IMAGE_VERSION) --force

build/concent-api/concent-api.tar: $(CONCENT_DIR)
	mkdir --parents $(dir $@)
	package-builder/build-concent-api.sh "$(CONCENT_DIR)" "build/concent-api"

build/nginx-proxy/concent-api-assets.tar: $(CONCENT_DIR)
	mkdir --parents "$(dir $@)"
	package-builder/build-concent-api-assets.sh \
		"$(CONCENT_DIR)"                        \
		"$(abspath package-builder)"            \
		"$(abspath build)"                      \
		"$(dir $@)"

build/nginx-proxy/concent-api-docs.tar: $(CONCENT_DIR)
	mkdir --parents $(dir $@)
	package-builder/build-concent-api-docs.sh   \
		"$(CONCENT_DIR)"                        \
		"$(abspath package-builder)"            \
		"$(abspath build)"                      \
		"$(dir $@)"

build/:
	mkdir --parents "$@"

# Static files
build/%: %
	cp --archive --parents "$<" build/

# Templates
build/%: %.j2 config.yml ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh config.yml "$<" "$@"

clean:
	rm -rf build/


.PHONY:                           \
    all                           \
    nginx-proxy nginx-proxy-clean \
    postgresql  postgresql-clean  \
    concent-api concent-api-clean \
    docker-clean                  \
    clean
