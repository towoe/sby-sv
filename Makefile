IMAGE_NAME?=towoe/sby-sv
BUILD_OPTS?=--network host \
            --force-rm=true \
            --layers=false
CONTAINER_TOOL=podman

image: Containerfile
	@$(CONTAINER_TOOL) build $(BUILD_OPTS) -t $(IMAGE_NAME) .

