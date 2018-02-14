# To be able to build 'arm' images on Travis (which is x64 based), it is mandatory to explicitly reference the arm32v6/alpine:3.7
# instead of 'alpine:3.7'
FROM arm32v6/alpine:3.7
COPY tmp/qemu-arm-static /usr/bin/qemu-arm-static

ENV VERSION=0.0.1

ARG VCS_REF
ARG BUILD_DATE

# See http://label-schema.org/rc1/
LABEL \
	org.label-schema.build-date=$BUILD_DATE \
	org.label-schema.vcs-ref=$VCS_REF \
	org.label-schema.vcs-url="https://github.com/biarms/test-build"
