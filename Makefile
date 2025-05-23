APP := app
REGISTRY ?= ghcr.io/savkaviktor16
VERSION := $(shell git describe --tags --abbrev=0)
BUILD_DIR := bin
ARCH ?= amd64
GOOS_LIST := linux windows darwin
IMAGE_TAG := ${REGISTRY}/${APP}:${VERSION}
TARGETOS ?= linux
TARGETARCH ?= amd64
CGO_ENABLED ?= 0
BINARY := $(APP)

.PHONY: clean

deps:
	go mod tidy

$(GOOS_LIST): deps
	@echo "Building for GOOS=$@, GOARCH=$(ARCH)..."
	GOOS=$@ GOARCH=$(ARCH) CGO_ENABLED=0 go build -v -o $(BUILD_DIR)/$(APP)-$@-$(ARCH)

build: deps
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) \
		go build -o /go/src/app/${BINARY} .

image:
	@echo "Building Docker image..."
	docker build -t $(IMAGE_TAG) .

push:
	@echo "Pushing Docker image..."
	docker push $(IMAGE_TAG)

start:
	@echo "Starting containers..."
	docker run $(IMAGE_TAG)

clean:
	@echo "Cleaning..."
	rm -rf $(BUILD_DIR)
	docker rmi $(IMAGE_TAG) || true