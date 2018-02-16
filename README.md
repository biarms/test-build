# biarms/test-build

[![build status](https://api.travis-ci.org/biarms/test-build.svg?branch=master)](https://travis-ci.org/biarms/test-build)

The goal of this git repo is to understand how works `docker pull` in a multi-architecture world (arm32v6, arm32v7, arm64v8, etc.) when using [docker manifest file](https://docs.docker.com/registry/spec/manifest-v2-2/#manifest-list)

Test images are be pushed on [dockerhub](https://hub.docker.com/r/biarms/test-build/).

Source code is available on [github](https://github.com/biarms/test-build)

Other references: 
1. https://github.com/docker-library/official-images#architectures-other-than-amd64
2. https://github.com/estesp/manifest-tool
3. `docker run --rm --privileged multiarch/qemu-user-static:register --reset`




## How docker manifest is working ?

First of all, let's see the docker manifest of the famous 'hello-world' image:
`docker run --rm mplatform/mquery hello-world`
Image: hello-world
 * Manifest List: Yes
 * Supported platforms:
   - linux/amd64
   - linux/arm/v5
   - linux/arm/v7
   - linux/arm64/v8
   - linux/386
   - linux/ppc64le
   - linux/s390x
   - windows/amd64:10.0.14393.2068
   - windows/amd64:10.0.16299.248

If I run that message, I get that result:
```
$ docker run --rm hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
fb62b039222f: Pull complete
Digest: sha256:083de497cff944f969d8499ab94f07134c50bcf5e6b9559b27182d3fa80ce3f7
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (arm32v5)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
[...]
```
The important point to notice is the "arm32v5" reference !

Obviously, I have now a local image:
```
$ docker images | grep hello
hello-world                     latest                                  75280d40a50b        2 months ago        1.69kB
```

I can see it is the same as `arm32v5/hello-world`:
```
$ docker run --rm arm32v5/hello-world
Unable to find image 'arm32v5/hello-world:latest' locally
latest: Pulling from arm32v5/hello-world
Digest: sha256:226b5aa93ef7c5070c0a1455659ea0d3cb58777c6826c7c31439049eec5984bf
Status: Downloaded newer image for arm32v5/hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (arm32v5)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
[...]
```
Then
```
$ docker images | grep hello
hello-world                     latest                                  75280d40a50b        2 months ago        1.69kB
arm32v5/hello-world             latest                                  75280d40a50b        2 months ago        1.69kB
```

That's a shame, because my cpu was able to handle the arm32v7 image:
```
$ docker run --rm arm32v7/hello-world
Unable to find image 'arm32v7/hello-world:latest' locally
latest: Pulling from arm32v7/hello-world
aaf92c0e26a5: Pull complete
Digest: sha256:9373f24532a8dfd786c4b581b76bc2f6328517526e9526b90071b920539b2368
Status: Downloaded newer image for arm32v7/hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (arm32v7)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
[...]
```

Final docker image status:
```
odroid@odroid:~$ docker images | grep hello
arm32v7/hello-world             latest                                  a0a916f95f26        2 months ago        1.64kB
arm32v5/hello-world             latest                                  75280d40a50b        2 months ago        1.69kB
hello-world                     latest                                  75280d40a50b        2 months ago        1.69kB
```

The docker manifest for another image is:
```
$ docker run --rm mplatform/mquery busybox
Image: busybox
 * Manifest List: Yes
 * Supported platforms:
   - linux/amd64
   - linux/arm/v5
   - linux/arm/v6
   - linux/arm/v7
   - linux/arm64/v8
   - linux/386
   - linux/ppc64le
   - linux/s390x
```


## Conclusions:
1. Apparently, docker download the first matching image in the list, and don't care if there is a 'better matching' image.
2. The mapping of architecture seams to be:

|docker official image prefix|docker manifest| uname -a  | Sample devices                                  |
|----------------------------|---------------|-----------|-------------------------------------------------|
|          arm32v5           |linux/arm/v5   | ???       | TS-7700                                         |
|          arm32v6           |linux/arm/v6   | armv6l    | RPI 1                                           |
|          arm32v7           |linux/arm/v7   | armv7l    | RPI 2-3, Odroid XU4 (running a with 32 bits OS) |
|          arm64v8           |linux/arm64/v8 | aarch64   | RPI 2-3, Odroid XU4 (running a with 64 bits OS) |