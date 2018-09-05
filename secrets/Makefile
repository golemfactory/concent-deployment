
ifndef CLUSTER
    $(error CLUSTER parameter not specified)
endif
$(info CLUSTER=$(CLUSTER))

ifndef CONCENT_SECRET_DIR
    CONCENT_SECRET_DIR := $(abspath ../../concent-secrets/$(CLUSTER))
endif
$(info CONCENT_SECRET_DIR=$(CONCENT_SECRET_DIR))

ifndef DEPLOYMENT_VAR_DIR
    DEPLOYMENT_VAR_DIR := $(abspath ../kubernetes)
endif
$(info CONCENT_SECRET_DIR=$(CONCENT_SECRET_DIR))


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
    build/concent-api-secrets/secrets/django-admin-fixture.yaml   \
    build/concent-api-secrets/apply-secrets.sh                    \
    build/concent-api-secrets/delete-secrets.sh

ifeq ($(CLUSTER),$(filter $(CLUSTER), concent-dev concent-staging))
    CLUSTER_SECRETS :=                                                     \
        $(CLUSTER_SECRETS)                                                 \
        build/concent-api-secrets/templates/signing-service-secrets.yml
endif

all: cluster-secrets

cluster-secrets: $(CLUSTER_SECRETS) | build/

build/:
	mkdir --parents "$@"

# Static file
build/concent-api-secrets/%: %
	cp --archive --parents "$<" build/concent-api-secrets/

build/vars-merged.yml: $(DEPLOYMENT_VAR_DIR)/var-$(CLUSTER).yml $(CONCENT_SECRET_DIR)/cluster-secrets.yml ../tools/merge-yaml.py
	../tools/merge-yaml.py           \
		"$(word 1,$^)"               \
		"$(word 2,$^)"               \
		--output "$@"

# Templates
build/concent-api-secrets/%: %.j2 build/vars-merged.yml ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh build/vars-merged.yml "$<" "$@"

# Secret file
build/concent-api-secrets/static-files/%: $(CONCENT_SECRET_DIR)/%
	mkdir --parents $(dir $@)
	cp --archive "$<" $(dir $@)

build/concent-api-secrets/templates/nginx-%-secrets.yml: build/concent-api-secrets/static-files/nginx-%-ssl.crt build/concent-api-secrets/static-files/nginx-%-ssl.key
	mkdir --parents $(dir $@)
	kubectl create secret generic $(notdir $(basename $@))      \
		--from-file=$(notdir $(word 1,$^))=$(word 1,$^)         \
		--from-file=$(notdir $(word 2,$^))=$(word 2,$^)         \
		--dry-run                                               \
		--output yaml > $@

build/concent-api-secrets/templates/concent-api-secrets.yml: build/concent-api-secrets/static-files/secrets.py build/concent-api-secrets/static-files/nginx-proxy-ssl.crt build/concent-api-secrets/static-files/nginx-storage-ssl.crt
	kubectl create secret generic $(notdir $(basename $@))      \
		--from-file=$(notdir $(word 1,$^))=$(word 1,$^)         \
		--from-file=$(notdir $(word 2,$^))=$(word 2,$^)         \
		--from-file=$(notdir $(word 3,$^))=$(word 3,$^)         \
		--dry-run                                               \
		--output yaml > $@

build/concent-api-secrets/templates/django-admin-fixture.yml: build/concent-api-secrets/secrets/django-admin-fixture.yaml
	kubectl create secret generic $(notdir $(basename $@))      \
		--from-file=$(notdir $<)=$<                             \
		--dry-run                                               \
		--output yaml > $@

clean:
	rm -rf build/

.PHONY: all cluster-secrets clean

