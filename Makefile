APP := $(shell basename -s .git $(shell git remote get-url origin))
REGISTRY ?= ghcr.io/savkaviktor16
VERSION := $(shell git describe --tags --abbrev=0)
BUILD_DIR := bin
ARCH ?= amd64
GOOS_LIST := linux windows darwin
TARGETOS ?= linux
TARGETARCH ?= amd64
CGO_ENABLED ?= 0
BINARY := $(APP)

.PHONY: clean

deps:
	go mod tidy

test:
	go test -v

$(GOOS_LIST): deps
	@echo "Building for GOOS=$@, GOARCH=$(ARCH)..."
	GOOS=$@ GOARCH=$(ARCH) CGO_ENABLED=0 go build -v -o $(BUILD_DIR)/$(APP)-$@-$(ARCH)

build: deps
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) \
		go build -o /go/src/app/${BINARY} .

image:
	@echo "Building Docker image..."
	docker build . -t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--build-arg VERSION=$(VERSION) \
		--build-arg TARGETOS=$(TARGETOS)

push:
	@echo "Pushing Docker image..."
	docker push $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

start:
	@echo "Starting containers..."
	docker run $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

clean:
	@echo "Cleaning..."
	rm -rf $(BUILD_DIR)
	docker rmi $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) || true