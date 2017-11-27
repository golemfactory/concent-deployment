CLUSTER_SCRIPTS :=                                     \
	build/services/nginx-proxy.yml                     \
	build/services/concent-api.yml                     \
	build/create-config-maps.sh                        \
	build/delete-config-maps.sh                        \
	build/create-services.sh                           \
	build/delete-services.sh                           \
	build/push-docker-images.sh                        \
	build/config-maps/nginx-proxy/default.conf         \
	build/config-maps/concent-api/local_settings.py    \
	build/concent-secrets/secrets.py

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
build/%: %.j2 vars.yml ../tools/render-jinja-template.sh
	../tools/render-jinja-template.sh vars.yml "$<" "$@"

clean:
	rm -rf build/

.PHONY: all cluster-scripts clean
