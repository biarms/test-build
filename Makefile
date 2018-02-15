default:
	docker build --build-arg BUILD_ARCH=arm32v7 --build-arg QEMU_ARCH=arm -t biarms/test-build:build .
	docker run --rm biarms/test-build:build
