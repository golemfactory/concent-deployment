CLUSTER_SCRIPTS :=                                            \
    build/services/nginx-proxy.yml                            \
    build/services/concent-api.yml                            \
    build/services/concent-api-worker.yml                     \
    build/services/gatekeeper.yml                             \
    build/services/conductor.yml                              \
    build/services/conductor-worker.yml                       \
    build/services/nginx-storage.yml                          \
    build/services/geth.yml                                   \
    build/services/rabbitmq.yml                               \
    build/services/signing-service.yml                        \
    build/services/verifier.yml                               \
    build/services/middleman.yml                              \
    build/create-job-dependencies.sh                          \
    build/delete-job-dependencies.sh                          \
    build/clean-up-jobs.sh                                    \
    build/create-config-maps.sh                               \
    build/delete-config-maps.sh                               \
    build/create-services.sh                                  \
    build/wait-until-ready.sh                                 \
    build/wait-until-kubectl-job-is-completed.sh              \
    build/sleep-until-kubectl-status-is-ready.sh              \
    build/delete-services.sh                                  \
    build/run-unit-tests.sh                                   \
    build/docker_testing.py                                   \
    build/push-docker-images.sh                               \
    build/config-maps/nginx-proxy/configs/http.conf           \
    build/config-maps/nginx-proxy/configs/ssl.conf            \
    build/config-maps/nginx-proxy/configs/tcp.conf            \
    build/config-maps/nginx-proxy/nginx.conf                  \
    build/config-maps/concent/email_settings.py               \
    build/config-maps/concent/timing_settings.py              \
    build/config-maps/gatekeeper/local_settings.py            \
    build/config-maps/conductor-worker/local_settings.py      \
    build/config-maps/conductor/local_settings.py             \
    build/config-maps/verifier/local_settings.py              \
    build/config-maps/middleman/local_settings.py             \
    build/config-maps/concent-api/local_settings.py           \
    build/config-maps/concent-api-worker/local_settings.py    \
    build/config-maps/database-jobs/local_settings.py         \
    build/config-maps/nginx-storage/default.conf              \
    build/config-maps/nginx-storage/ssl.conf                  \
    build/config-maps/nginx-storage/file-transfer-config.lua  \
    build/jobs/reset-control-database.yml                     \
    build/jobs/migrate-control-database.yml                   \
    build/jobs/reset-storage-database.yml                     \
    build/jobs/migrate-storage-database.yml



ifndef CLUSTER
    $(error CLUSTER parameter not specified)
endif
$(info CLUSTER=$(CLUSTER))

ifndef DEPLOYMENT_VALUES_DIR
    DEPLOYMENT_VALUES_DIR := $(abspath .)
endif
$(info DEPLOYMENT_VALUES_DIR=$(DEPLOYMENT_VALUES_DIR))

ifndef IMAGE_VERSION
    IMAGE_VERSION := $(shell git describe --always --abbrev=16)
endif
$(info IMAGE_VERSION=$(IMAGE_VERSION))


all: cluster-scripts

cluster-scripts: build/ $(CLUSTER_SCRIPTS)

build/:
	mkdir --parents "$@"

# Static file
build/%: %
	cp --archive --parents "$<" build/

# Templates
build/%: %.j2 build/vars-merged.yml ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh build/vars-merged.yml "$<" "$@"

build/jobs/%-control-database.yml: jobs/%-database.yml.j2 ../tools/render-jinja-template.sh build/vars-with-control-database-config.yml
	../tools/render-jinja-template.sh build/vars-with-control-database-config.yml "$<" "$@"

build/jobs/%-storage-database.yml: jobs/%-database.yml.j2 ../tools/render-jinja-template.sh build/vars-with-storage-database-config.yml
	../tools/render-jinja-template.sh build/vars-with-storage-database-config.yml "$<" "$@"

build/vars-with-%-database-config.yml: build/%-database-configuration.yml build/vars-merged.yml
	../tools/merge-yaml.py                         \
		"$<"                                       \
		"build/vars-merged.yml"                    \
		--output "$@"

build/vars-merged.yml: $(DEPLOYMENT_VALUES_DIR)/var.yml $(DEPLOYMENT_VALUES_DIR)/var-$(CLUSTER).yml build/image-version.yml ../containers/versions.yml ../tools/merge-yaml.py
	../tools/merge-yaml.py                                \
		"$<"                                              \
		"$(DEPLOYMENT_VALUES_DIR)/var-$(CLUSTER).yml"     \
		"build/image-version.yml"                         \
		../containers/versions.yml                        \
		--output "$@"

build/%-database-configuration.yml:
	echo "selected_database_id:    $*"  >> "$@"
	echo "database_name:          \"{{ concent_versions[concent_version].$*_database_name | default($*_database_name) }}\"" >> "$@"
	echo "database_user:          \"{{ $*_database_user }}\"" >> "$@"
	echo "database_host:          \"{{ $*_database_host }}\"" >> "$@"
	if [ '$*' = 'control' ]; then                      \
	    echo "initialize_django_admin: true" >> "$@";  \
	fi

build/image-version.yml:
	echo "image_version: $(IMAGE_VERSION)" >> "$@"

clean:
	rm -rf build/

.PHONY: all cluster-scripts clean
