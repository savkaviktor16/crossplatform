APP := crossp
REGISTRY ?= ghcr.io/savkaviktor16
BUILD_DIR := bin
ARCH ?= amd64
GOOS_LIST := linux windows darwin
GOOS := $(shell go env GOOS)
GOARCH := $(shell go env GOARCH)
BINARY := $(APP)-$(GOOS)-$(GOARCH)
IMAGE_TAG := ${REGISTRY}/${APP}:

.PHONY: clean

all: $(GOOS_LIST)

$(GOOS_LIST):
	@echo "Building for GOOS=$@, GOARCH=$(ARCH)..."
	GOOS=$@ GOARCH=$(ARCH) CGO_ENABLED=0 go build -v -o $(BUILD_DIR)/$(APP)-$@-$(ARCH)

deps:
	go mod tidy

build:
	@echo "Building for GOOS=$(GOOS), GOARCH=$(GOARCH)..."
	GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go build -v -o $(BUILD_DIR)/$(BINARY)

docker-build:
	@echo "Building Docker image for platform $(GOOS)/$(GOARCH)..."
	docker buildx build \
		--platform=$(GOOS)/$(GOARCH) \
		--build-arg BINARY=$(BINARY) \
		--build-arg BUILD_DIR=$(BUILD_DIR) \
		-t $(IMAGE_TAG) .

docker-push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	@echo "Cleaning..."
	rm -rf $(BUILD_DIR)
	docker rmi $(IMAGE_TAG) || true

stop:
	@echo "Stopping containers..."
	docker stop $$(docker ps -q --filter "name=$(IMAGE_TAG)") || true
	docker rm $$(docker ps -aq --filter "name=$(IMAGE_TAG)") || true