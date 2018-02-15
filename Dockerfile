# Perform a multi-stage build as explained at https://docs.docker.com/v17.09/engine/userguide/eng-image/multistage-build/#name-your-build-stages
FROM biarms/qemu-bin:latest as qemu-bin-ref

# To be able to build 'arm' images on Travis (which is x64 based), it is mandatory to explicitly reference the arm32v6/alpine:3.7
# instead of 'alpine:3.7'
FROM arm32v6/alpine:3.7
# COPY tmp/qemu-arm-static /usr/bin/qemu-arm-static
# ADD https://github.com/multiarch/qemu-user-static/releases/download/v2.9.1-1/qemu-arm-static /usr/bin/qemu-arm-static
COPY --from=qemu-bin-ref /usr/bin/qemu-arm-static /usr/bin/qemu-arm-static

ENV VERSION=0.0.1
CMD ["echo", "I am an arm32v6 image", "&&", "uname", "-a" ]

# See http://label-schema.org/rc1/
ARG BUILD_DATE
ARG VCS_REF
LABEL \
	org.label-schema.build-date=$BUILD_DATE \
	org.label-schema.vcs-ref=$VCS_REF \
	org.label-schema.vcs-url="https://github.com/biarms/test-build"
