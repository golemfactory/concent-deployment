CLUSTER_SCRIPTS :=                                          \
    build/services/nginx-proxy.yml                          \
    build/services/concent-api.yml                          \
    build/services/gatekeeper.yml                           \
    build/services/conductor.yml                            \
    build/services/nginx-storage.yml                        \
    build/services/geth.yml                                 \
    build/services/rabbitmq.yml                             \
    build/create-job-dependencies.sh                        \
    build/delete-job-dependencies.sh                        \
    build/clean-up-jobs.sh                                  \
    build/create-config-maps.sh                             \
    build/delete-config-maps.sh                             \
    build/create-services.sh                                \
    build/delete-services.sh                                \
    build/run-unit-tests.sh                                 \
    build/docker_testing.py                                 \
    build/push-docker-images.sh                             \
    build/config-maps/nginx/error-pages.conf                \
    build/config-maps/nginx-proxy/default.conf              \
    build/config-maps/nginx-proxy/ssl.conf                  \
    build/config-maps/concent/email_settings.py             \
    build/config-maps/concent/timing_settings.py            \
    build/config-maps/gatekeeper/local_settings.py          \
    build/config-maps/conductor/local_settings.py           \
    build/config-maps/concent-api/local_settings.py         \
    build/config-maps/database-jobs/local_settings.py       \
    build/config-maps/nginx-storage/default.conf            \
    build/config-maps/nginx-storage/ssl.conf                \
    build/concent-secrets/secrets.py                        \
    build/concent-secrets/nginx-proxy-ssl.crt               \
    build/concent-secrets/nginx-proxy-ssl.key               \
    build/concent-secrets/nginx-storage-ssl.crt             \
    build/concent-secrets/nginx-storage-ssl.key             \
    build/secrets/control-db-secrets.yml                    \
    build/secrets/storage-db-secrets.yml                    \
    build/secrets/django-admin-fixture.yaml                 \
    build/jobs/create-control-database.yml                  \
    build/jobs/migrate-control-database.yml                 \
    build/jobs/delete-control-database.yml                  \
    build/jobs/create-storage-database.yml                  \
    build/jobs/migrate-storage-database.yml                 \
    build/jobs/delete-storage-database.yml



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

build/jobs/%-control-database.yml: jobs/%-database.yml.j2 ../tools/render-jinja-template.sh build/vars-with-control-database-config-and-secrets.yml
	../tools/render-jinja-template.sh build/vars-with-control-database-config-and-secrets.yml "$<" "$@"

build/jobs/%-storage-database.yml: jobs/%-database.yml.j2 ../tools/render-jinja-template.sh build/vars-with-storage-database-config-and-secrets.yml
	../tools/render-jinja-template.sh build/vars-with-storage-database-config-and-secrets.yml "$<" "$@"

build/secrets/%-db-secrets.yml: build/vars-with-%-database-config-and-secrets.yml secrets/db-secrets.yml.j2 ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh "$<" "secrets/db-secrets.yml.j2" "$@"

build/vars-with-%-database-config-and-secrets.yml: build/%-database-configuration.yml build/vars-merged-with-secrets.yml
	../tools/merge-yaml.py                         \
		"$<"                                       \
		"build/vars-merged-with-secrets.yml"       \
		--output "$@"

build/vars-merged-with-secrets.yml: var.yml var-$(CLUSTER).yml $(CONCENT_SECRET_DIR)/var-secret.yml build/image-version.yml ../containers/versions.yml ../tools/merge-yaml.py
	../tools/merge-yaml.py                     \
		"$<"                                   \
		"var-$(CLUSTER).yml"                   \
		"$(CONCENT_SECRET_DIR)/var-secret.yml" \
		"build/image-version.yml"              \
		../containers/versions.yml             \
		--output "$@"

build/image-version.yml:
	echo "image_version: $(IMAGE_VERSION)" >> "$@"

build/control-database-configuration.yml:
	echo "selected_database_id:    control"  >> "$@"
	echo "database_name:          \"{{ control_database_name }}\"" >> "$@"
	echo "database_user:          \"{{ control_database_user }}\"" >> "$@"
	echo "database_host:          \"{{ control_database_host }}\"" >> "$@"
	echo "initialize_django_admin: true" >> "$@"
	echo "db_admin_password:      \"{{ control_db_admin_password }}\"" >> "$@"
	echo "db_user_password:       \"{{ control_db_user_password }}\"" >> "$@"

build/storage-database-configuration.yml:
	echo "selected_database_id:   storage" >> "$@"
	echo "database_name:         \"{{ storage_database_name }}\"" >> "$@"
	echo "database_user:         \"{{ storage_database_user }}\"" >> "$@"
	echo "database_host:         \"{{ storage_database_host }}\"" >> "$@"
	echo "db_admin_password:     \"{{ storage_db_admin_password }}\"" >> "$@"
	echo "db_user_password:      \"{{ storage_db_user_password }}\"" >> "$@"

clean:
	rm -rf build/

.PHONY: all cluster-scripts clean
