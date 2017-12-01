CLUSTER_SCRIPTS :=                                     \
	build/services/nginx-proxy.yml                     \
	build/services/concent-api.yml                     \
	build/create-job-dependencies.sh                   \
	build/delete-job-dependencies.sh                   \
	build/clean-up-jobs.sh                             \
	build/create-config-maps.sh                        \
	build/delete-config-maps.sh                        \
	build/create-services.sh                           \
	build/delete-services.sh                           \
	build/push-docker-images.sh                        \
	build/config-maps/nginx-proxy/default.conf         \
	build/config-maps/concent-api/local_settings.py    \
	build/concent-secrets/secrets.py                   \
	build/secrets/db-secrets.yml                       \
	build/secrets/django-admin-fixture.yaml            \
	build/jobs/create-database.yml                     \
	build/jobs/migrate-database.yml                    \
	build/jobs/delete-database.yml                     \
	build/config-maps/nginx-storage/default.conf       \
	build/services/nginx-storage.yml

ifndef CONCENT_SECRET_DIR
	CONCENT_SECRET_DIR:= $(abspath ../../concent-secrets)
endif
$(info CONCENT_SECRET_DIR=$(CONCENT_SECRET_DIR))

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

build/vars-merged-with-secrets.yml: var.yml $(CONCENT_SECRET_DIR)/var-secret.yml ../tools/merge-yaml.py
	../tools/merge-yaml.py "$<" $(CONCENT_SECRET_DIR)/var-secret.yml --output "$@"


clean:
	rm -rf build/

.PHONY: all cluster-scripts clean
