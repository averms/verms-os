#!/usr/bin/env bash
set -eu
shopt -s inherit_errexit

build-verms() {
    _oci --tag verms-os -f verms.Dockerfile
    podman image scp localhost/verms-os:latest root@localhost::
}

build-toolbox() {
    _oci --tag toolbox -f toolbox.Dockerfile
}

push-verms() {
    podman push --creds averms verms-os:latest ghcr.io/averms/verms-os:latest
}

build-qcow2() {
    _image ./qemu_config.toml \
        --local --type qcow2 --rootfs xfs localhost/verms-os:latest
}

build-iso() {
    _image ./iso_config.toml \
        --local --type anaconda-iso --rootfs xfs localhost/verms-os:latest
}

help() {
    echo "$0 <task> [args]"
    echo
    compgen -A function | grep -v '^_' | cat -n
}

_oci() {
    podman build --pull=newer --build-arg MAJOR_VERSION=41 "$@"
}

_image() {
    local config="$1"
    shift

    sudo podman run --pull=newer --rm -it --privileged --security-opt label=disable \
        -v ./output:/output \
        -v "${config}:/config.toml:ro" \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        quay.io/centos-bootc/bootc-image-builder:latest \
        "$@"
}

TIMEFORMAT="Task completed in %3lR"
time "${@:-help}"
