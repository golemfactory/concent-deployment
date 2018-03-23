NGINX_PROXY_SOURCE :=               \
    build/nginx-proxy/Dockerfile    \
    build/nginx-proxy/index.html    \

NGINX_STORAGE_SOURCE :=                            \
    build/nginx-storage/Dockerfile                 \
    build/nginx-storage/install-dependencies.sh    \
    build/nginx-storage/table_utils.lua

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

VERIFIER_SOURCE_FROM_CONCENT_API :=          \
    build/verifier/install-concent-api.sh    \
    build/verifier/concent-api-manage.sh     \
    build/verifier/testing.pref              \
    build/verifier/requirements.lock         \
    build/verifier/concent-api.tar           \
    build/verifier/local_settings.py

VERIFIER_SOURCE :=                           \
    build/verifier/entrypoint.sh             \
    build/verifier/install-dependencies.sh   \
    build/verifier/run-celery.sh             \
    build/verifier/Dockerfile                \
    $(VERIFIER_SOURCE_FROM_CONCENT_API)


ifndef CONCENT_DIR
    CONCENT_DIR:= $(abspath ../../concent)
endif
$(info CONCENT_DIR=$(CONCENT_DIR))

ifndef GOLEM_DIR
    GOLEM_DIR:= $(abspath ../../golem)
endif
$(info GOLEM_DIR=$(GOLEM_DIR))

ifndef IMAGE_VERSION
    IMAGE_VERSION := $(shell git describe --always)
endif
$(info IMAGE_VERSION=$(IMAGE_VERSION))

ifndef IMAGE_PREFIX
    IMAGE_PREFIX :=
endif
$(info IMAGE_PREFIX=$(IMAGE_PREFIX))


all: build/ nginx-proxy nginx-storage concent-api postgresql verifier

nginx-proxy: $(NGINX_PROXY_SOURCE) build/nginx-proxy/concent-api-assets.tar build/nginx-proxy/concent-api-docs.tar
	docker build -t $(IMAGE_PREFIX)nginx-proxy:$(IMAGE_VERSION) build/nginx-proxy/
	docker tag $(IMAGE_PREFIX)nginx-proxy:$(IMAGE_VERSION) $(IMAGE_PREFIX)nginx-proxy:latest

nginx-storage: $(NGINX_STORAGE_SOURCE)
	docker build -t $(IMAGE_PREFIX)nginx-storage:$(IMAGE_VERSION) build/nginx-storage/
	docker tag $(IMAGE_PREFIX)nginx-storage:$(IMAGE_VERSION) $(IMAGE_PREFIX)nginx-storage:latest

postgresql: $(POSTGRESQL_SOURCE)
	docker build -t $(IMAGE_PREFIX)postgresql:$(IMAGE_VERSION) build/postgresql/
	docker tag $(IMAGE_PREFIX)postgresql:$(IMAGE_VERSION) $(IMAGE_PREFIX)postgresql:latest

concent-api: $(CONCENT_API_SOURCE) build/concent-api/requirements.lock build/concent-api/testing.pref
	docker build -t $(IMAGE_PREFIX)concent-api:$(IMAGE_VERSION) build/concent-api/
	docker tag $(IMAGE_PREFIX)concent-api:$(IMAGE_VERSION) $(IMAGE_PREFIX)concent-api:latest

verifier: $(VERIFIER_SOURCE) build/verifier/golem/scripts/ build/verifier/golem/imgverifier-requirements.txt
	docker build --tag $(IMAGE_PREFIX)verifier:$(IMAGE_VERSION) build/verifier/
	docker tag $(IMAGE_PREFIX)verifier:$(IMAGE_VERSION) $(IMAGE_PREFIX)verifier:latest

docker-clean: nginx-proxy-clean concent-api-clean postgresql-clean verifier-clean

nginx-proxy-clean:
	docker rmi $(IMAGE_PREFIX)nginx-proxy:$(IMAGE_VERSION) --force

nginx-storage-clean:
	docker rmi $(IMAGE_PREFIX)nginx-storage:$(IMAGE_VERSION) --force

postgresql-clean:
	docker rmi $(IMAGE_PREFIX)postgresql:$(IMAGE_VERSION) --force

concent-api-clean:
	docker rmi $(IMAGE_PREFIX)concent-api:$(IMAGE_VERSION) --force

verifier-clean:
	docker rmi $(IMAGE_PREFIX)verifier:$(IMAGE_VERSION) --force

build/virtualenv/: $(CONCENT_DIR)/concent_api/requirements.lock build/package-builder/build-virtualenv.sh
	build/package-builder/build-virtualenv.sh "$<" "build"

build/concent-api/requirements.lock: build/concent-api/concent-api.tar
	tar                                          \
		--extract                                \
		--strip=1                                \
		--file build/concent-api/concent-api.tar \
		--directory build/concent-api/           \
		concent_api/requirements.lock

build/concent-api/testing.pref: ../concent-builder/files/testing.pref
	cp "$<" "$@"

build/concent-api/concent-api.tar: $(CONCENT_DIR)  build/virtualenv/
	mkdir --parents $(dir $@)
	package-builder/build-concent-api.sh "$(CONCENT_DIR)" "build/concent-api"


build/nginx-proxy/concent-api-assets.tar: $(CONCENT_DIR) build/virtualenv/ build/package-builder/build-concent-api-assets.sh
	mkdir --parents "$(dir $@)"
	build/package-builder/build-concent-api-assets.sh \
		"$(CONCENT_DIR)"                              \
		"$(abspath package-builder)"                  \
		"$(abspath build)"                            \
		"$(dir $@)"

build/nginx-proxy/concent-api-docs.tar: $(CONCENT_DIR) build/package-builder/build-concent-api-docs.sh
	mkdir --parents $(dir $@)
	build/package-builder/build-concent-api-docs.sh   \
		"$(CONCENT_DIR)"                              \
		"$(abspath package-builder)"                  \
		"$(abspath build)"                            \
		"$(dir $@)"

$(VERIFIER_SOURCE_FROM_CONCENT_API): build/verifier/%: build/concent-api/%
	mkdir --parents "build/verifier/"
	cp "$<" "$@"

build/verifier/golem/scripts/: $(GOLEM_DIR)/apps/rendering/resources/scripts/
	mkdir --parents "$@"
	cp  --recursive "$<." "$@"


build/verifier/golem/imgverifier-requirements.txt: $(GOLEM_DIR)/apps/rendering/resources/images/requirements.txt
	cp "$<" "$@"

build/:
	mkdir --parents "$@"

# Static files
build/%: %
	cp --archive --parents "$<" build/

# Templates
build/%: %.j2 build/config-with-versions.yml ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh         \
		build/config-with-versions.yml        \
		"$<"                                  \
		"$@"

build/config-with-versions.yml: versions.yml config.yml ../tools/merge-yaml.py
	../tools/merge-yaml.py                     \
		"$<"                                   \
		"config.yml"                           \
		--output "$@"


clean:
	rm -rf build/


.PHONY:                                 \
    all                                 \
    nginx-proxy   nginx-proxy-clean     \
    nginx-storage nginx-storage-clean   \
    postgresql    postgresql-clean      \
    concent-api   concent-api-clean     \
    verifier      verifier-clean        \
    docker-clean                        \
    clean
