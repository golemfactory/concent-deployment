CLUSTER_SCRIPTS :=                                     \
	build/services/nginx-proxy.yml                     \
	build/create-config-maps.sh                        \
	build/delete-config-maps.sh                        \
	build/create-services.sh                           \
	build/delete-services.sh                           \
	build/push-docker-images.sh                        \
	build/config-maps/nginx-proxy/default.conf

all: cluster-scripts

cluster-scripts: build/ $(CLUSTER_SCRIPTS)

build/:
	mkdir --parents "$@"

# Static file
build/%: %
	cp --archive --parents "$<" build/

# Templates
build/%: %.j2 var.yml
	mkdir --parents $(dir $@)
	yasha --variables var.yml "$<" --output "$@"

	# Copy file permissions from the source file
	chown --reference="$<" "$@"
	chmod --reference="$<" "$@"

clean:
	rm -rf build/

.PHONY: all cluster-scripts clean
