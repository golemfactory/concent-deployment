CLUSTER_SECRETS :=                                                \
    build/concent-api-secrets/static-files/secrets.py             \
    build/concent-api-secrets/static-files/var-secret.yml         \
    build/concent-api-secrets/static-files/nginx-proxy-ssl.crt    \
    build/concent-api-secrets/static-files/nginx-proxy-ssl.key    \
    build/concent-api-secrets/static-files/nginx-storage-ssl.crt  \
    build/concent-api-secrets/static-files/nginx-storage-ssl.key  \
    build/concent-api-secrets/templates/nginx-proxy-secrets.yml   \
    build/concent-api-secrets/templates/nginx-storage-secrets.yml \
    build/concent-api-secrets/templates/control-db-secrets.yml    \
    build/concent-api-secrets/templates/storage-db-secrets.yml    \
    build/concent-api-secrets/templates/django-admin-fixture.yml  \
    build/concent-api-secrets/templates/concent-api-secrets.yml   \
    build/install-or-upgrade-secrets.sh                           \
    build/delete-secrets.sh                                       \
    build/concent-api-secrets/Chart.yaml



ifndef CLUSTER
    $(error CLUSTER parameter not specified)
endif

ifndef SECRET_VERSION
    $(error SECRET_VERSION parameter not specified)
endif

$(info CLUSTER=$(CLUSTER))
ifndef CONCENT_SECRET_DIR
    CONCENT_SECRET_DIR := $(abspath ../../concent-secrets/$(CLUSTER))
endif
$(info CONCENT_SECRET_DIR=$(CONCENT_SECRET_DIR))

all: cluster-secrets concent-api-secrets-$(SECRET_VERSION).tgz

concent-api-secrets-$(SECRET_VERSION).tgz: cluster-secrets
	cd build && helm package concent-api-secrets/

cluster-secrets: build/ $(CLUSTER_SECRETS)

build/:
	mkdir --parents "$@"

# Static file
build/concent-api-secrets/%: %
	cp --archive --parents "$<" build/concent-api-secrets/

# Templates
build/%: %.j2 build/concent-api-secrets/static-files/var-secret.yml ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh build/concent-api-secrets/static-files/var-secret.yml "$<" "$@"

# Secret file
build/concent-api-secrets/static-files/%: $(CONCENT_SECRET_DIR)/%
	mkdir --parents $(dir $@)
	cp --archive "$<" $(dir $@)

build/concent-api-secrets/templates/nginx-%-secrets.yml: build/concent-api-secrets/static-files/nginx-%-ssl.crt build/concent-api-secrets/static-files/nginx-%-ssl.key
	mkdir --parents $(dir $@)
	kubectl create secret generic $(notdir $(basename $@))      \
		--from-file=$(notdir $<)=$<                             \
		--from-file=$(notdir $(word 2,$^))=$(word 2,$^)         \
		--dry-run                                               \
		-o yaml > $@

# Need update to `nginx-storage.crt` after separate to cluster control and storage
build/concent-api-secrets/templates/concent-api-secrets.yml: build/concent-api-secrets/static-files/secrets.py build/concent-api-secrets/static-files/nginx-proxy-ssl.crt
	kubectl create secret generic $(notdir $(basename $@))      \
		--from-file=$(notdir $<)=$<                             \
		--from-file=$(notdir $(word 2,$^))=$(word 2,$^)         \
		--dry-run                                               \
		-o yaml > $@

build/concent-api-secrets/templates/django-admin-fixture.yml: build/secrets/django-admin-fixture.yaml
	kubectl create secret generic $(notdir $(basename $@))      \
		--from-file=$(notdir $<)=$<                             \
		--dry-run                                               \
		-o yaml > $@


build/concent-api-secrets/templates/%-db-secrets.yml: build/vars-with-%-database-config-and-secrets.yml templates/db-secrets.yml.j2 ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh "$<" "templates/db-secrets.yml.j2" "$@"

build/vars-with-%-database-config-and-secrets.yml: build/%-database-configuration.yml build/concent-api-secrets/static-files/var-secret.yml
	../tools/merge-yaml.py                              \
		"$<"                                            \
		"build/concent-api-secrets/static-files/var-secret.yml"          \
		--output "$@"

build/%-database-configuration.yml:
	echo "selected_database_id:    $*"  >> "$@"
	echo "db_admin_password:      \"{{ $*_db_admin_password }}\"" >> "$@"
	echo "db_user_password:       \"{{ $*_db_user_password }}\"" >> "$@"

clean:
	rm -rf build/

.PHONY: all cluster-secrets clean

