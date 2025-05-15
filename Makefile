APP := crossp
REGISTRY ?= ghcr.io/savkaviktor16
VERSION := $(shell git describe --tags --abbrev=0)
BUILD_DIR := bin
ARCH ?= amd64
GOOS_LIST := linux windows darwin
IMAGE_TAG := ${REGISTRY}/${APP}:${VERSION}
PLATFORMS=linux/amd64,linux/arm64

.PHONY: clean

$(GOOS_LIST):
	@echo "Building for GOOS=$@, GOARCH=$(ARCH)..."
	GOOS=$@ GOARCH=$(ARCH) CGO_ENABLED=0 go build -v -o $(BUILD_DIR)/$(APP)-$@-$(ARCH)

deps:
	go mod tidy

image:
	@echo "Building Docker image..."
	docker buildx build \
		--platform=$(PLATFORMS) \
		--build-arg BINARY=app \
		-t $(IMAGE_TAG) \
		--push .

start:
	@echo "Starting containers..."
	docker run $(IMAGE_TAG)

clean:
	@echo "Cleaning..."
	rm -rf $(BUILD_DIR)
	docker rmi $(IMAGE_TAG) || true