IMAGE_NAME?=docker.io/towoe/sby-sv
BUILD_OPTS?=--network host \
            --force-rm=true \
            --format=docker \
            --layers=false
CONTAINER_TOOL=docker

image: Containerfile
	@$(CONTAINER_TOOL) build $(BUILD_OPTS) -t $(IMAGE_NAME) .

