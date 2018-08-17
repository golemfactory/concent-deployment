NGINX_PROXY_SOURCE :=              \
	build/nginx-proxy/Dockerfile     \
	build/nginx-proxy/index.html     \
	build/nginx-proxy/error-pages.conf

NGINX_STORAGE_SOURCE_FROM_NGINX_PROXY :=\
	build/nginx-storage/error-pages.conf

NGINX_STORAGE_SOURCE :=                           \
	build/nginx-storage/Dockerfile                  \
	build/nginx-storage/install-dependencies.sh     \
	build/nginx-storage/table_utils.lua             \
	build/nginx-storage/file-transfer-config.lua    \
	build/nginx-storage/file-transfer-endpoints.lua \
	build/nginx-storage/file-transfer-endpoints.conf\
	build/nginx-storage/default.conf                \
	$(NGINX_STORAGE_SOURCE_FROM_NGINX_PROXY)

POSTGRESQL_SOURCE :=                 \
	build/postgresql/Dockerfile        \
	build/postgresql/delete-database.sh\
	build/postgresql/create-database.sh

CONCENT_API_SOURCE :=                      \
	build/concent-api/install-concent-api.sh \
	build/concent-api/install-dependencies.sh\
	build/concent-api/Dockerfile             \
	build/concent-api/concent-api-manage.sh  \
	build/concent-api/run-celery.sh          \
	build/concent-api/run-gunicorn.sh        \
	build/concent-api/local_settings.py

VERIFIER_SOURCE_FROM_CONCENT_API :=    \
	build/verifier/install-concent-api.sh\
	build/verifier/concent-api-manage.sh \
	build/verifier/run-celery.sh         \
	build/verifier/testing.pref          \
	build/verifier/requirements.lock     \
	build/verifier/concent-api.tar       \
	build/verifier/local_settings.py

VERIFIER_SOURCE :=                      \
	build/verifier/entrypoint.sh          \
	build/verifier/install-dependencies.sh\
	build/verifier/Dockerfile             \
	$(VERIFIER_SOURCE_FROM_CONCENT_API)

ifndef IMAGE_VERSION
	IMAGE_VERSION := $(shell git describe --always --abbrev=16)
endif
$(info IMAGE_VERSION=$(IMAGE_VERSION))

ifndef IMAGE_PREFIX
	IMAGE_PREFIX :=
endif
$(info IMAGE_PREFIX=$(IMAGE_PREFIX))

IMAGE_TARGETS :=\
	nginx-proxy   \
	nginx-storage \
	postgresql    \
	concent-api   \
	verifier      \

nginx-proxy!dependencies:                 \
	$(NGINX_PROXY_SOURCE)                   \
	build/nginx-proxy/concent-api-assets.tar\
	build/nginx-proxy/concent-api-docs.tar

nginx-storage!dependencies:\
	$(NGINX_STORAGE_SOURCE)

concent-api!dependencies:            \
	$(CONCENT_API_SOURCE)              \
	build/concent-api/requirements.lock\
	build/concent-api/testing.pref     \
	build/repositories/concent/

postgresql!dependencies:\
	$(POSTGRESQL_SOURCE)

verifier!dependencies:                            \
	$(VERIFIER_SOURCE)                              \
	build/repositories/golem/                       \
	build/verifier/golem/scripts/                   \
	build/verifier/golem/imgverifier-requirements.txt

all: $(IMAGE_TARGETS)

$(IMAGE_TARGETS): %: %!dependencies build/
	docker build --tag $(IMAGE_PREFIX)$@:$(IMAGE_VERSION) build/$@/
	docker tag $(IMAGE_PREFIX)$@:$(IMAGE_VERSION) $(IMAGE_PREFIX)$@:latest

docker-clean: nginx-proxy-rmi nginx-storage-rmi postgresql-rmi concent-api-rmi verifier-rmi

%-rmi:
	docker rmi $(IMAGE_PREFIX)$*:$(IMAGE_VERSION) --force

build/virtualenv/: build/repositories/concent/concent_api/requirements.lock build/package-builder/build-virtualenv.sh
	build/package-builder/build-virtualenv.sh "$<" "build"

build/concent-api/requirements.lock: build/concent-api/concent-api.tar
	tar                                        \
		--extract                                \
		--strip=1                                \
		--file build/concent-api/concent-api.tar \
		--directory build/concent-api/           \
		concent_api/requirements.lock

build/concent-api/testing.pref: ../concent-builder/files/testing.pref
	cp "$<" "$@"

build/concent-api/concent-api.tar: build/repositories/concent/  build/virtualenv/
	mkdir --parents $(dir $@)
	package-builder/build-concent-api.sh "build/repositories/concent/" "build/concent-api"

build/nginx-proxy/concent-api-assets.tar: build/repositories/concent/ build/virtualenv/ build/package-builder/build-concent-api-assets.sh
	mkdir --parents "$(dir $@)"
	build/package-builder/build-concent-api-assets.sh\
		"build/repositories/concent/"                  \
		"$(abspath package-builder)"                   \
		"$(abspath build)"                             \
		"$(dir $@)"

build/nginx-proxy/concent-api-docs.tar: build/repositories/concent/ build/package-builder/build-concent-api-docs.sh
	mkdir --parents $(dir $@)
	build/package-builder/build-concent-api-docs.sh\
		"build/repositories/concent/"                \
		"$(abspath package-builder)"                 \
		"$(abspath build)"                           \
		"$(dir $@)"

$(VERIFIER_SOURCE_FROM_CONCENT_API): build/verifier/%: build/concent-api/%
	mkdir --parents "build/verifier/"
	cp "$<" "$@"

build/verifier/golem/scripts/: build/repositories/golem/apps/rendering/resources/scripts/
	mkdir --parents "$@"
	cp  --recursive "$<." "$@"

$(NGINX_STORAGE_SOURCE_FROM_NGINX_PROXY): build/nginx-storage/%: build/nginx-proxy/%
	mkdir --parents "build/nginx-storage/"
	cp "$<" "$@"

build/verifier/golem/imgverifier-requirements.txt: build/repositories/golem/apps/rendering/resources/images/requirements.txt
	cp "$<" "$@"

build/repositories/concent/: build/package-builder/clone-or-update.sh /var/concent-data/concent
	build/package-builder/clone-or-update.sh "concent" "$@"

build/repositories/golem/: build/package-builder/clone-or-update.sh /var/concent-data/golem
	build/package-builder/clone-or-update.sh  "golem" "$@"

build/:
	mkdir --parents "$@"

# Static files
build/%: %
	cp --archive --parents "$<" build/

# Templates
build/%: %.j2 build/config-with-versions.yml ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh\
		build/config-with-versions.yml \
		"$<"                           \
		"$@"

build/config-with-versions.yml: versions.yml config.yml ../tools/merge-yaml.py
	../tools/merge-yaml.py\
		"$<"                \
		"config.yml"        \
		--output "$@"

clean:
	rm -rf build/

.PHONY:                            \
	all                              \
	nginx-proxy   nginx-proxy-clean  \
	nginx-storage nginx-storage-clean\
	postgresql    postgresql-clean   \
	concent-api   concent-api-clean  \
	verifier      verifier-clean     \
	docker-clean                     \
	clean                            \
	%-rmi
