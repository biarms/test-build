# biarms/test-build

[![build status](https://api.travis-ci.org/biarms/test-build.svg?branch=master)](https://travis-ci.org/biarms/test-build)

The goal of this git repo is to understand how works `docker pull` in a multi-architecture world (arm32v6, arm32v7, arm64v8, etc.) when using [docker manifest file](https://docs.docker.com/registry/spec/manifest-v2-2/#manifest-list)

Test images are pushed on [dockerhub](https://hub.docker.com/r/biarms/test-build/).

Source code is available on [github](https://github.com/biarms/test-build).

## Prerequisites to understand what we are talking about:
To understand this 'project', you should have read (and understood):
1. https://github.com/docker-library/official-images#architectures-other-than-amd64
2. https://github.com/estesp/mquery
3. https://github.com/estesp/manifest-tool
4. https://github.com/multiarch/qemu-user-static
5. https://blog.hypriot.com/post/setup-simple-ci-pipeline-for-arm-images/
Therefore, you should know what `docker run --rm --privileged multiarch/qemu-user-static:register --reset` is for.


## How docker manifest files are working ?

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



## Testing with my images

The docker meta data for my 'travis build' images are always 'amd64/linux', even if actually, it is not true. That's certainly related to the 'qemu' emulation build hack:
```
$ docker run --rm mplatform/mquery biarms/test-build:linux-arm32v6-0.0.1
Image: biarms/test-build:linux-arm32v6-0.0.1
 * Manifest List: No
 * Supports: amd64/linux

$ docker run --rm mplatform/mquery biarms/test-build:linux-arm32v7-0.0.1
Image: biarms/test-build:linux-arm32v7-0.0.1
 * Manifest List: No
 * Supports: amd64/linux
```

It is not the case of the hello-world images, that were probably build on the correct hardware, without emulation:
```
$ docker run --rm mplatform/mquery arm32v5/hello-world
Image: arm32v5/hello-world
 * Manifest List: Yes
 * Supported platforms:
   - linux/arm/v5
$ docker run --rm mplatform/mquery arm64v8/hello-world
Image: arm64v8/hello-world
 * Manifest List: Yes
 * Supported platforms:
   - linux/arm64/v8
```

Now, let's play with my images. For release 0.0.1, I have created a manifest that looks like:
```
$ docker run --rm mplatform/mquery biarms/test-build:0.0.1
Image: biarms/test-build:0.0.1
 * Manifest List: Yes
 * Supported platforms:
   - linux/arm64/v8
   - linux/arm/v7
   - linux/arm/v6
```
Be caution to the order: arm/v7 is before arm/v6


If I run the `docker run --rm biarms/test-build:0.0.1` command on my odroid, I get:
```
odroid@odroid:~$ docker run --rm biarms/test-build:0.0.1
Unable to find image 'biarms/test-build:0.0.1' locally
0.0.1: Pulling from biarms/test-build
Digest: sha256:0ffb34d13e137500c3286310c196c31440bddca45fefc8cf443cf1130085eef5
Status: Downloaded newer image for biarms/test-build:0.0.1
I am an 'arm32v7' image and I am embedding the 'arm' qemu binary
odroid@odroid:~$ docker version
Client:
 Version:	18.02.0-ce
 API version:	1.36
 Go version:	go1.9.3
 Git commit:	fc4de44
 Built:	Wed Feb  7 21:23:44 2018
 OS/Arch:	linux/arm
 Experimental:	false
 Orchestrator:	swarm
 ```

```
pi@raspberrypi:~ $ docker run --rm biarms/test-build:0.0.1
Unable to find image 'biarms/test-build:0.0.1' locally
0.0.1: Pulling from biarms/test-build
Digest: sha256:0ffb34d13e137500c3286310c196c31440bddca45fefc8cf443cf1130085eef5
Status: Downloaded newer image for biarms/test-build:0.0.1
pi@raspberrypi:~ $ docker version
Client:
 Version:	18.02.0-ce
 API version:	1.36
 Go version:	go1.9.3
 Git commit:	fc4de44
 Built:	Wed Feb  7 21:24:08 2018
 OS/Arch:	linux/arm
 Experimental:	false
 Orchestrator:	swarm
```

Check carefully: no "I am an 'arm32v7' image and I am embedding the 'arm' qemu binary" output on my raspberry pi1, while the arm/v6 was there !


## Conclusions:
1. Apparently, docker download the first matching image in the list, and don't care if there is a 'better matching' image.
2. It is IMPORTANT to order the docker manifest file !
2. The 'meta data' of an image build with the 'qemu' emulator technique will not have correct manifest (but that's not a big deal: if a correct docker manifest is published, referencing that image, then it is the 'docker manifest' that is considered)
3. The mapping of architecture 'labels' seams to be:

|docker official image prefix|docker manifest| uname -a  | Sample devices                                  |
|----------------------------|---------------|-----------|-------------------------------------------------|
|          arm32v5           |linux/arm/v5   | ???       | TS-7700                                         |
|          arm32v6           |linux/arm/v6   | armv6l    | RPI 1                                           |
|          arm32v7           |linux/arm/v7   | armv7l    | RPI 2-3, Odroid XU4 (running a with 32 bits OS) |
|          arm64v8           |linux/arm64/v8 | aarch64   | RPI 2-3, Odroid XU4 (running a with 64 bits OS) |