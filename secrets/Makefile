CLUSTER_SECRETS :=                                            \
    build/concent-secrets/secrets.py                          \
    build/concent-secrets/var-secret.yml                      \
    build/concent-secrets/nginx-proxy-ssl.crt                 \
    build/concent-secrets/nginx-proxy-ssl.key                 \
    build/concent-secrets/nginx-storage-ssl.crt               \
    build/concent-secrets/nginx-storage-ssl.key               \
    build/templates/nginx-proxy-secrets.yml                   \
    build/templates/nginx-storage-secrets.yml                 \
    build/templates/control-db-secrets.yml                    \
    build/templates/storage-db-secrets.yml                    \
    build/templates/django-admin-fixture.yml                  \
    build/templates/concent-api-secrets.yml                   \
    build/apply-secrets.sh                                    \
    build/delete-secrets.sh


ifndef CLUSTER
    $(error CLUSTER parameter not specified)
endif

$(info CLUSTER=$(CLUSTER))
ifndef CONCENT_SECRET_DIR
    CONCENT_SECRET_DIR := $(abspath ../../concent-secrets/$(CLUSTER))
endif
$(info CONCENT_SECRET_DIR=$(CONCENT_SECRET_DIR))

all: cluster-secrets

cluster-secrets: build/ $(CLUSTER_SECRETS)

build/:
	mkdir --parents "$@"

# Static file
build/%: %
	cp --archive --parents "$<" build/

# Templates
build/%: %.j2 build/concent-secrets/var-secret.yml ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh build/concent-secrets/var-secret.yml "$<" "$@"

# Secret file
build/concent-secrets/%: $(CONCENT_SECRET_DIR)/%
	mkdir --parents $(dir $@)
	cp --archive "$<" $(dir $@)

build/templates/nginx-%-secrets.yml: build/concent-secrets/nginx-%-ssl.crt build/concent-secrets/nginx-%-ssl.key
	mkdir --parents $(dir $@)
	kubectl create secret generic $(notdir $(basename $@))      \
		--from-file=$(notdir $<)=$<                             \
		--from-file=$(notdir $(word 2,$^))=$(word 2,$^)         \
		--dry-run                                               \
		-o yaml > $@

# Need update to `nginx-storage.crt` after separate to cluster control and storage
build/templates/concent-api-secrets.yml: build/concent-secrets/secrets.py build/concent-secrets/nginx-proxy-ssl.crt
	kubectl create secret generic $(notdir $(basename $@))      \
		--from-file=$(notdir $<)=$<                             \
		--from-file=$(notdir $(word 2,$^))=$(word 2,$^)         \
		--dry-run                                               \
		-o yaml > $@

build/templates/django-admin-fixture.yml: build/secrets/django-admin-fixture.yaml
	kubectl create secret generic $(notdir $(basename $@))      \
		--from-file=$(notdir $<)=$<                             \
		--dry-run                                               \
		-o yaml > $@


build/templates/%-db-secrets.yml: build/vars-with-%-database-config-and-secrets.yml templates/db-secrets.yml.j2 ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh "$<" "templates/db-secrets.yml.j2" "$@"

build/vars-with-%-database-config-and-secrets.yml: build/%-database-configuration.yml build/concent-secrets/var-secret.yml
	../tools/merge-yaml.py                              \
		"$<"                                            \
		"build/concent-secrets/var-secret.yml"          \
		--output "$@"

build/%-database-configuration.yml:
	echo "selected_database_id:    $*"  >> "$@"
	echo "db_admin_password:      \"{{ $*_db_admin_password }}\"" >> "$@"
	echo "db_user_password:       \"{{ $*_db_user_password }}\"" >> "$@"

clean:
	rm -rf build/

.PHONY: all cluster-secrets clean
