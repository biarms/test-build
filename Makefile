default:
	docker build --build-arg BUILD_ARCH=arm32v7 --build-arg QEMU_ARCH=arm -t test .
	docker run --rm test
