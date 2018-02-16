ARG BUILD_ARCH
# Perform a multi-stage build as explained at https://docs.docker.com/v17.09/engine/userguide/eng-image/multistage-build/#name-your-build-stages
FROM biarms/qemu-bin:latest as qemu-bin-ref

FROM ${BUILD_ARCH}/busybox
# ARG BUILD_ARCH line was duplicated on purpose: "An ARG declared before a FROM is outside of a build stage, so it can’t be used in any instruction after a FROM."
# See https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG BUILD_ARCH
ARG QEMU_ARCH
# COPY tmp/qemu-arm-static /usr/bin/qemu-arm-static
# ADD https://github.com/multiarch/qemu-user-static/releases/download/v2.9.1-1/qemu-arm-static /usr/bin/qemu-arm-static
COPY --from=qemu-bin-ref /usr/bin/qemu-${QEMU_ARCH}-static /usr/bin/qemu-${QEMU_ARCH}-static

RUN echo "I am an '${BUILD_ARCH}' image and I am embedding the '${QEMU_ARCH}' qemu binary" > /root/info.txt

CMD ["cat", "/root/info.txt"]
ENV VERSION=0.0.1

# See http://label-schema.org/rc1/
ARG BUILD_DATE
ARG VCS_REF
LABEL \
	org.label-schema.build-date=$BUILD_DATE \
	org.label-schema.vcs-ref=$VCS_REF \
	org.label-schema.vcs-url="https://github.com/biarms/test-build"

