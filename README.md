# erlang-build linux

This is a implementation and also PoC for [Linux Build SDK](https://github.com/erlef/erlang-build-proposal/blob/main/linux-build-sdk.md) part of [Erlang Builds proposal](https://github.com/erlef/erlang-build-proposal/tree/main).

The main targets here are:

 - make sure that github workflows are viable when building Yocto images
 - make sure it is possible to run QEMU with action [docker/setup-qemu-action](https://github.com/docker/setup-qemu-action) in order to natively build Erlang/OTP
 - implement a Yocto layer with specific elements for building an OCI container with development and build dependencies
 - evaluate tools and scanners (SBOM, license reports, etc)

TODO:

- Add multiple Erlang/OTP versions
- Add tools and process for SBOM, license report, etc
- Improve CI flows for releasing build artifacts
- Reduce Erlang/OTP binaries, it is for debugging right now.

## Yocto side

We use [Yocto Project](https://www.yoctoproject.org/) for making SDK build environment where we have the full control of
all elements, versions, configurations, and tooling. This is a key point for providing Erlang/OTP binaries that works on all
modern Linux distributions.

### kas

For manage Yocto builds, the kas tool is used in order to organize and reuse configuration fragments. So, 
the `kas` folder defines yaml kas fragments and the following _entry points_ were defined:

 - `kas/demos/genericarm64-musl.yml`
 - `kas/demos/genericx86-64.yml`
 - `kas/demos/genericarm64-musl.yml`
 - `kas/demos/genericarm64.yml`

 The above configuration are prepared to build a combination between LIBC and MACHINES. Others configurations could be easily added when needed.

 Right now, we are based on _scarthgap_ release due its LTS maintenance. And the `poky` distro is being used just for reference.

## meta-erlang-build layer

A new layer called _meta-erlang-build_ is also provided it follows Yocto standard layer guides. That layer is responsible for defining a linux based image called erlang-build-container-image which has all the requirements, libraries and tools tailored for building Erlang/OTP from source code. Actually, that image will be transformed
into an OCI container during Yocto build.

The mentioned layer also has some patches for _gcc_ recipes. Because we want to build Erlang/OTP binaries that can be run in any linux box. To get this
done it was necessary to change how gcc behaves removing a specific path applied by Yocto.

## patches

There is some additional patches applied for Yocto scarthgap. We don't want to carry on patches, however the following patches were needed:

- [ncurses: allow user to change ncurses ABI version](patches/0001-ncurses-allow-user-to-change-ncurses-ABI-version.patch), by default Yocto builds ncurses
following ABI 5. Where most of linux distros moved to ABI 6. For our use case, it's better also use ABI 6.

## Build instructions

This repository builds multiple Yocto OCI containers for specific combinations like:

 - LIBC: glibc, musl
 - Machine: genericarm64, genericx86-64

So, the challenge is to find common configuration that implements all the possible combinations.

There are two Makefiles used to keep all build commands:

 - `Makefile`, builds Yocto SDK OCI container. Example:

    ```
    make shell genericx86-64-musl
    ```

 - `Makefile.oci`, based on previous results adds each OCI container into a manifest and pushes to ghcr.io. Example:

    ```
    make login
    make collect
    make manifests
    ```

## Continuous Integration

 - `.github/workflows/yocto-sdk-containers.yml`, this workflow builds and publishes SDK as OCI containers. It
 uses OCI manifests in order to publish OCI containers as multi platforms, https://github.com/joaohf/erlang-build-linux/pkgs/container/erlang-build.
 The is one OCI container for each LIBC.

 - `.github/workflows/erlang-build.yml`, this workflow is responsible for building Erlang/OTP from source code and
 publishing as tarball at https://github.com/joaohf?tab=packages&repo_name=erlang-build-linux
