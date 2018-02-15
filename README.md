# biarms/test-build

[![build status](https://api.travis-ci.org/biarms/test-build.svg?branch=master)](https://travis-ci.org/biarms/test-build)

The goal of this git repo is to understand how works `docker pull` in a multi-architecture world (arm32v6, arm32v7, arm64v8, etc.) when using [docker manifest file](https://docs.docker.com/registry/spec/manifest-v2-2/#manifest-list)

Test images are be pushed on [dockerhub](https://hub.docker.com/r/biarms/test-build/).

Source code is available on [github](https://github.com/biarms/test-build)

Other references: 
1. https://github.com/docker-library/official-images#architectures-other-than-amd64
2. https://github.com/estesp/manifest-tool
3. `docker run --rm --privileged multiarch/qemu-user-static:register --reset`
