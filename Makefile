SHELL = bash

DOCKER_IMAGE_NAME=biarms/test-build

default: build test

check:
	@docker version > /dev/null
	@if [[ "${BUILD_ARCH}" == "" ]]; then \
		echo 'BUILD_ARCH is unset (MUST BE SET !)' && \
		echo 'Sample usage: QEMU_ARCH=arm BUILD_ARCH=arm32v7 make' && \
        exit 1; \
	fi
	@if [[ "$(QEMU_ARCH)" == "" ]]; then \
		echo 'QEMU_ARCH is unset (MUST BE SET !)' && \
		echo 'Sample usage: QEMU_ARCH=arm BUILD_ARCH=arm32v7 make' && \
		exit 2; \
	fi
	@echo "DOCKER_REGISTRY: $(DOCKER_REGISTRY)"

build: check
	docker build --build-arg BUILD_ARCH=${BUILD_ARCH} --build-arg QEMU_ARCH=${QEMU_ARCH} -t ${DOCKER_IMAGE_NAME}:build .

test: check
	uname -a
	docker run --rm $(DOCKER_IMAGE_NAME):build
	docker run --rm $(DOCKER_IMAGE_NAME):build uname -a
