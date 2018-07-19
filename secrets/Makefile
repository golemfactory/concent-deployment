
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


CLUSTER_SECRETS :=                                            \
    $(CONCENT_SECRET_DIR)/secrets.py                          \
    $(CONCENT_SECRET_DIR)/var-secret.yml                      \
    $(CONCENT_SECRET_DIR)/nginx-proxy-ssl.crt                 \
    $(CONCENT_SECRET_DIR)/nginx-proxy-ssl.key                 \
    $(CONCENT_SECRET_DIR)/nginx-storage-ssl.crt               \
    $(CONCENT_SECRET_DIR)/nginx-storage-ssl.key               \
    build/templates/nginx-proxy-secrets.yml                   \
    build/templates/nginx-storage-secrets.yml                 \
    build/templates/control-db-secrets.yml                    \
    build/templates/storage-db-secrets.yml                    \
    build/templates/django-admin-fixture.yml                  \
    build/templates/concent-api-secrets.yml                   \
    build/apply-secrets.sh                                    \
    build/delete-secrets.sh

ifeq ($(CLUSTER),$(filter $(CLUSTER), concent-dev concent-staging))
    CLUSTER_SECRETS :=                               \
        $(CLUSTER_SECRETS)                           \
        build/templates/signing-service-secrets.yml
endif

all: cluster-secrets

cluster-secrets: $(CLUSTER_SECRETS) | build/

build/:
	mkdir --parents "$@"

# Static file
build/%: %
	cp --archive --parents "$<" build/

build/vars-merged.yml: $(DEPLOYMENT_VAR_DIR)/var-$(CLUSTER).yml $(CONCENT_SECRET_DIR)/var-secret.yml ../tools/merge-yaml.py
	../tools/merge-yaml.py           \
		"$(word 1,$^)"               \
		"$(word 2,$^)"               \
		--output "$@"

# Templates
build/%: %.j2 build/vars-merged.yml ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh build/vars-merged.yml "$<" "$@"

build/templates/nginx-%-secrets.yml: $(CONCENT_SECRET_DIR)/nginx-%-ssl.crt $(CONCENT_SECRET_DIR)/nginx-%-ssl.key
	mkdir --parents $(dir $@)
	kubectl create secret generic $(notdir $(basename $@))      \
		--from-file=$(notdir $(word 1,$^))=$(word 1,$^)         \
		--from-file=$(notdir $(word 2,$^))=$(word 2,$^)         \
		--dry-run                                               \
		--output yaml > $@

build/templates/concent-api-secrets.yml: $(CONCENT_SECRET_DIR)/secrets.py $(CONCENT_SECRET_DIR)/nginx-proxy-ssl.crt $(CONCENT_SECRET_DIR)/nginx-storage-ssl.crt
	kubectl create secret generic $(notdir $(basename $@))      \
		--from-file=$(notdir $(word 1,$^))=$(word 1,$^)         \
		--from-file=$(notdir $(word 2,$^))=$(word 2,$^)         \
		--from-file=$(notdir $(word 3,$^))=$(word 3,$^)         \
		--dry-run                                               \
		--output yaml > $@

build/templates/django-admin-fixture.yml: build/secrets/django-admin-fixture.yaml
	kubectl create secret generic $(notdir $(basename $@))      \
		--from-file=$(notdir $<)=$<                             \
		--dry-run                                               \
		--output yaml > $@

clean:
	rm -rf build/

.PHONY: all cluster-secrets clean
