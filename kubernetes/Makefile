CLUSTER_SCRIPTS :=                                          \
    build/services/nginx-proxy.yml                          \
    build/services/concent-api.yml                          \
    build/services/gatekeeper.yml                           \
    build/services/nginx-storage.yml                        \
    build/services/geth.yml                                 \
    build/create-job-dependencies.sh                        \
    build/delete-job-dependencies.sh                        \
    build/clean-up-jobs.sh                                  \
    build/create-config-maps.sh                             \
    build/delete-config-maps.sh                             \
    build/create-services.sh                                \
    build/delete-services.sh                                \
    build/push-docker-images.sh                             \
    build/config-maps/nginx/error-pages.conf                \
    build/config-maps/nginx-proxy/default.conf              \
    build/config-maps/nginx-proxy/ssl.conf                  \
    build/config-maps/gatekeeper/local_settings.py          \
    build/config-maps/concent-api/local_settings.py         \
    build/config-maps/nginx-storage/default.conf            \
    build/concent-secrets/secrets.py                        \
    build/concent-secrets/nginx-proxy-ssl.crt               \
    build/concent-secrets/nginx-proxy-ssl.key               \
    build/secrets/db-secrets.yml                            \
    build/secrets/django-admin-fixture.yaml                 \
    build/jobs/create-database.yml                          \
    build/jobs/migrate-database.yml                         \
    build/jobs/delete-database.yml

ifndef CLUSTER
    $(error CLUSTER parameter not specified)
endif
$(info CLUSTER=$(CLUSTER))

ifndef CONCENT_SECRET_DIR
    CONCENT_SECRET_DIR := $(abspath ../../concent-secrets/$(CLUSTER))
endif
$(info CONCENT_SECRET_DIR=$(CONCENT_SECRET_DIR))

ifndef IMAGE_VERSION
    IMAGE_VERSION := "latest"
endif
$(info IMAGE_VERSION=$(IMAGE_VERSION))


all: cluster-scripts

cluster-scripts: build/ $(CLUSTER_SCRIPTS)

build/:
	mkdir --parents "$@"

# Static file
build/%: %
	cp --archive --parents "$<" build/

# Secret file
build/concent-secrets/%: $(CONCENT_SECRET_DIR)/%
	mkdir --parents $(dir $@)
	cp --archive "$<" $(dir $@)


# Templates
build/%: %.j2 build/vars-merged-with-secrets.yml ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh build/vars-merged-with-secrets.yml "$<" "$@"

build/vars-merged-with-secrets.yml: var.yml var-$(CLUSTER).yml $(CONCENT_SECRET_DIR)/var-secret.yml build/image-version.yml ../tools/merge-yaml.py
	../tools/merge-yaml.py                     \
		"$<"                                   \
		"var-$(CLUSTER).yml"                   \
		"$(CONCENT_SECRET_DIR)/var-secret.yml" \
		"build/image-version.yml"              \
		--output "$@"

build/image-version.yml:
	echo "image_version: $(IMAGE_VERSION)" >> build/image-version.yml

clean:
	rm -rf build/

.PHONY: all cluster-scripts clean
